defmodule ChessWeb.Live.Interactive do
  use ChessWeb, :live_view
  require Logger

  @initial_turn :white

  defp initial_board(params) do
    if Map.has_key?(params, "crazy") do
      Chess.Board.Presets.Crazy.standard(:white, :black);
    else
      Chess.Board.Presets.standard(:white, :black);
    end
  end

  @impl true
  def mount(params = %{"id" => id}, _session, socket) do
    if connected?(socket) do
      game_state = Chess.GameState.get_game(id)

      color = cond do
	Map.has_key?(params, "observer") -> :observer
	game_state && game_state.started -> :black
	true -> :white
      end

      turn = if(game_state == :nil, do: @initial_turn, else: game_state.turn)
      board = if(game_state == :nil, do: initial_board(params), else: game_state.board)

      Chess.PubSub.subscribe("#{id}")
      Chess.GameState.create_game(id, %{board: board, turn: turn, started: color != :observer})

      {:ok, socket
            |> assign(:game, id)
            |> assign(:board, board)
            |> assign(:result, nil)
            |> assign(:turn, turn)
            |> assign(:player_color, color)
            |> assign(:selected_square, nil)
            |> assign(:valid_moves, [])}
    else
      #Logger.info "Waiting to connect with ID"
      {:ok, socket}
    end
  end

  @impl true
  def mount(params, session, socket) do # Entry point for new games
    mount(Map.put(params, "id", generate_game_id()), session, socket )
  end

  # Render function remains unchanged
  @impl true
  def render(assigns) do
    cond do
      assigns[:board] == nil ->
~H"""
<center> <h2> Connecting to chess game... </h2> </center>
"""
      true ->
~H"""
<div class="">
    <%= if @game do %>
    <div class="text-center mb-4">
	<div>Game ID: <%= @game %></div>
	<%= if @player_color do %>
	<div>You are playing as: <%= @player_color %></div>
	<% else %>
	<div>Waiting for opponent...</div>
	<% end %>
    </div>
    <% end %>

    <%= if @result != nil do %>
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
        <div class="bg-white p-8 rounded-lg shadow-lg text-center">
            <h2 class="text-2xl font-bold mb-4"><%= @result %></h2>
            <a href="/" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                New game
            </a>
        </div>
    </div>
    <% end %>

    <div class="chess-board" phx-hook="Game" id="game-board" data-game-id={@game}>
	<%= for row <- 0..7 do %>
	<div class="row">
	    <%= for col <- 0..7 do %>
	    <%
	    piece = Map.get(@board.cells, [row, col])
	    is_selected = @selected_square == [row, col]
	    is_valid_move = [row, col] in @valid_moves
	    square_color = if rem(row + col, 2) == 0, do: "white", else: "black"
	    piece_data = if piece, do: Chess.Piece.glyphs()[piece.owner][piece.type]
	    %>
	    <div class={"square #{square_color} #{if is_selected, do: "selected"} #{if is_valid_move, do: "valid-move"}"}
		 phx-click="select_square"
		 phx-value-row={row}
		 phx-value-col={col}>
		<%= if piece_data do %>
		<span class={"chess-piece #{piece.type}"}>
		    <%= piece_data %>
		</span>
		<% end %>
	    </div>
	    <% end %>
	</div>
	<% end %>
    </div>
    <div class="text-center mt-4 text-xl font-bold">
	Current turn: <%= String.capitalize(to_string(@turn)) %>
    </div>
</div>
"""
    end
  end

  @impl true
  def handle_event("select_square", _, socket = %{player_color: :observer}), do: {:noreply, socket}

  @impl true
  def handle_event("select_square", %{"row" => row, "col" => col}, socket) do
    if socket.assigns.turn == socket.assigns.player_color do
      position = [String.to_integer(row), String.to_integer(col)]
      #Logger.info("Square clicked at position: #{inspect(position)}")
      
      cond do
        socket.assigns.selected_square != nil ->
          from = socket.assigns.selected_square
          #Logger.info("Moving from: #{inspect(from)} to: #{inspect(position)}")
          
          if position in Chess.Piece.Moves.get(socket.assigns.board, socket.assigns.board.cells[from], from) do
            new_board = Chess.Board.make_move(socket.assigns.board, position, from)
            new_turn = if(socket.assigns.turn == :white, do: :black, else: :white)

	    {result, socket} = game_status(socket, new_board.cells[position], position, socket.assigns.board);

            # Update game state
            Chess.GameState.create_game(socket.assigns.game, %{board: new_board, turn: new_turn, started: true})

            # Broadcast move using regular chess specific topic
	    #IO.puts("Broadcasting to #{@pubsub_topic_prefix}#{socket.assigns.game}");
            Chess.PubSub.broadcast("#{socket.assigns.game}", {:move_made, %{
								 board: new_board,
								 turn: new_turn,
								 result: result,
							      }})
	    IO.inspect new_turn, label: "NEW TURN"

            {:noreply, socket
	               |> assign(:board, new_board)
	               |> assign(:turn, new_turn)
	               |> assign(:result, result)
                       |> assign(:selected_square, nil)
                       |> assign(:valid_moves, [])}
          else
            #Logger.info("Invalid move attempted")
            {:noreply, socket |> assign(:selected_square, nil) |> assign(:valid_moves, [])}
          end

        true ->
          case Map.get(socket.assigns.board.cells, position) do
            nil ->
              #Logger.info("Empty square selected")
              {:noreply, socket |> assign(:selected_square, nil) |> assign(:valid_moves, [])}

            piece ->
              if piece.owner == socket.assigns.turn do # CHANGE TO CALCULATED COLOR
                #Logger.info("Selected piece: #{piece.owner} #{piece.type}")
                valid_moves = Chess.Piece.Moves.get(socket.assigns.board, piece, position)

                {:noreply, socket
		           |> assign(:selected_square, position)
		           |> assign(:valid_moves, valid_moves)}
              else
                #Logger.info("Selected opponent's piece")
                {:noreply, socket}
              end
          end
      end
    else
      #Logger.info("Move attempted on opponent's turn")
      {:noreply, socket}
    end
  end

  # Reads game state and updates socket accordingly. Does not modify the board.
  defp game_status(socket, last_moved_piece, moved_to, old_board) do
    white_pieces = Chess.Board.get_pieces(socket.assigns.board, :white)
    black_pieces = Chess.Board.get_pieces(socket.assigns.board, :black)
    enemy_king = Chess.Board.get_king(socket.assigns.board, if(socket.assigns.turn == :white, do: :black, else: :white));
    enemy_king_moves = Chess.Piece.Moves.get(socket.assigns.board, enemy_king);
    last_piece_moves = Chess.Piece.Moves.get(socket.assigns.board, last_moved_piece, moved_to);
    dest = old_board.cells[moved_to]

    cond do
      dest && dest.type == :king ->
	{"The #{dest.owner} king has been captured! #{socket.assigns.turn} wins!", socket}
      length(enemy_king_moves) > 0 && enemy_king_moves -- last_piece_moves == [] ->
	{"Checkmate! #{socket.assigns.turn} wins!", socket}
      length(Chess.Piece.Moves.get_all(socket.assigns.board, white_pieces)) == 0->
	{"White has no more moves! black wins!", socket}
      length(Chess.Piece.Moves.get_all(socket.assigns.board, black_pieces)) == 0 ->
	{"Black has no more moves! white wins!", socket}
      true-> 
	{nil, socket}
    end
  end

  # Handle incoming moves from PubSub
  @impl true
  def handle_info({:move_made, %{board: board, turn: turn, result: result}}, socket) do
    #Logger.info("Received move broadcast in regular chess")
    {:noreply, socket
               |> assign(:board, board)
               |> assign(:turn, turn)
               |> assign(:result, result)
               |> assign(:selected_square, nil)
               |> assign(:valid_moves, [])}
  end

  defp generate_game_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)
  end
end

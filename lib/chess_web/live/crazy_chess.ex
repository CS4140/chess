defmodule ChessWeb.Live.CrazyChess do
  use ChessWeb, :live_view
  require Logger

  # Define PubSub topic prefix for crazy chess games
  @pubsub_topic_prefix "crazy_game:"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Logger.info("Mounting Crazy Chess with ID: #{id}")
    
    if connected?(socket) do
      # Subscribe to crazy chess specific PubSub updates
      Chess.PubSub.subscribe("#{@pubsub_topic_prefix}#{id}")
      
      game_state = Chess.GameState.get_game(id)
      Logger.info("Game state for #{id}: #{inspect(game_state)}")
      
      case game_state do
        nil -> 
          Logger.info("No game found for ID: #{id}")
          {:ok, socket |> redirect(to: "/crazy")}
        game_state ->
          Logger.info("Joining existing game: #{id}")
          {:ok, socket |> assign(:game, id)
                      |> assign(:board, game_state.board)
                      |> assign(:turn, game_state.turn)
                      |> assign(:selected_square, nil)
                      |> assign(:valid_moves, [])
                      |> assign(:player_color, :black)}
      end
    else
      {:ok, socket |> assign(:game, id)
                  |> assign(:board, Chess.CrazyBoard.standard())
                  |> assign(:turn, :white)
                  |> assign(:selected_square, nil)
                  |> assign(:valid_moves, [])
                  |> assign(:player_color, :black)}
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    Logger.info("Mounting new Crazy Chess game")
    
    if connected?(socket) do
      game_id = generate_game_id()
      Logger.info("Generated new game ID: #{game_id}")

      # Subscribe to PubSub updates for the new game
      Chess.PubSub.subscribe("#{@pubsub_topic_prefix}#{game_id}")
      
      initial_state = %{
        board: Chess.CrazyBoard.standard(),
        turn: :white
      }
      
      Chess.GameState.create_game(game_id, initial_state)
      Logger.info("Saved initial state for game: #{game_id}")
      
      {:ok, socket |> assign(:game, game_id)
                  |> assign(:board, initial_state.board)
                  |> assign(:turn, initial_state.turn)
                  |> assign(:selected_square, nil)
                  |> assign(:valid_moves, [])
                  |> assign(:player_color, :white)}
    else
      {:ok, socket |> assign(:game, nil)
                  |> assign(:board, Chess.CrazyBoard.standard())
                  |> assign(:turn, :white)
                  |> assign(:selected_square, nil)
                  |> assign(:valid_moves, [])
                  |> assign(:player_color, :white)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="text-center mb-4 text-2xl font-bold">
        Crazy Chess
      </div>
      
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

      <div class="chess-board" phx-hook="Game" id="game-board" data-game-id={@game}>
        <%= for row <- 0..7 do %>
          <div class="row">
            <%= for col <- 0..7 do %>
              <%
                piece = Map.get(@board.cells, {row, col})
                is_selected = @selected_square == {row, col}
                is_valid_move = {row, col} in @valid_moves
                square_color = if rem(row + col, 2) == 0, do: "white", else: "black"
                piece_data = if piece, do: Chess.CrazyPiece.glyphs()[piece.color][piece.type]
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

      <div class="text-center mt-4">
        <div class="text-xl font-bold">
          Current turn: <%= String.capitalize(to_string(@turn)) %>
        </div>
        <div class="mt-4 grid grid-cols-2 gap-4 max-w-2xl mx-auto">
          <div class="bg-white p-4 rounded shadow">
            <h3 class="font-bold mb-2">Your Pieces:</h3>
            <div class="grid grid-cols-2 gap-2">
              <div>🐉 Dragon: Queen + Knight moves</div>
              <div>🧙‍♂️ Wizard: Teleport anywhere</div>
              <div>🥷 Ninja: Knight + adjacent moves</div>
              <div>🦅 Phoenix: Jumping diagonal moves</div>
            </div>
          </div>
          <div class="bg-white p-4 rounded shadow">
            <h3 class="font-bold mb-2">Special Rules:</h3>
            <ul class="text-sm">
              <li>Dragon can move like a queen or knight</li>
              <li>Wizard can teleport to any empty square</li>
              <li>Ninja combines knight and king movements</li>
              <li>Phoenix moves diagonally and can jump pieces</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("select_square", %{"row" => row, "col" => col}, socket) do
    if socket.assigns.turn == socket.assigns.player_color do
      position = {String.to_integer(row), String.to_integer(col)}
      Logger.info("Square clicked at position: #{inspect(position)}")
      
      cond do
        socket.assigns.selected_square != nil ->
          from = socket.assigns.selected_square
          Logger.info("Moving from: #{inspect(from)} to: #{inspect(position)}")
          
          piece = socket.assigns.board.cells[from]
          valid_moves = Chess.CrazyPiece.possible_moves(socket.assigns.board, piece, from)
          
          if position in valid_moves do
            new_board = Chess.CrazyBoard.make_move(socket.assigns.board, position, from)
            new_turn = if(socket.assigns.turn == :white, do: :black, else: :white)
            
            # Update game state and broadcast move
            if socket.assigns.game do
              Chess.GameState.create_game(socket.assigns.game, %{
                board: new_board,
                turn: new_turn
              })
              
              # Broadcast move using crazy chess specific topic
              Chess.PubSub.broadcast("#{@pubsub_topic_prefix}#{socket.assigns.game}", {:move_made, %{
                from: from,
                to: position,
                board: new_board,
                turn: new_turn
              }})
            end

            {:noreply, socket 
              |> assign(:board, new_board)
              |> assign(:turn, new_turn)
              |> assign(:selected_square, nil)
              |> assign(:valid_moves, [])}
          else
            Logger.info("Invalid move attempted")
            {:noreply, socket |> assign(:selected_square, nil) |> assign(:valid_moves, [])}
          end

        true ->
          case Map.get(socket.assigns.board.cells, position) do
            nil ->
              Logger.info("Empty square selected")
              {:noreply, socket |> assign(:selected_square, nil) |> assign(:valid_moves, [])}

            piece ->
              if piece.color == socket.assigns.turn do
                Logger.info("Selected piece: #{piece.color} #{piece.type}")
                valid_moves = Chess.CrazyPiece.possible_moves(socket.assigns.board, piece, position)
                {:noreply, socket |> assign(:selected_square, position) |> assign(:valid_moves, valid_moves)}
              else
                Logger.info("Selected opponent's piece")
                {:noreply, socket}
              end
          end
      end
    else
      Logger.info("Move attempted on opponent's turn")
      {:noreply, socket}
    end
  end

  # Handle incoming moves from PubSub
  @impl true
  def handle_info({:move_made, %{board: new_board, turn: new_turn}}, socket) do
    Logger.info("Received move broadcast in crazy chess")
    {:noreply, socket
      |> assign(:board, new_board)
      |> assign(:turn, new_turn)
      |> assign(:selected_square, nil)
      |> assign(:valid_moves, [])}
  end

  # Handle move broadcasts
  @impl true
  def handle_event("broadcast_move", %{"from" => from, "to" => to}, socket) do
    Logger.info("Broadcasting move in crazy chess")
    {:noreply, push_event(socket, "make_move", %{
      from: from,
      to: to,
      player: socket.assigns.player_color
    })}
  end

  defp generate_game_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)
  end
end

defmodule ChessWeb.Live.Interactive2 do
  use ChessWeb, :live_view
  require Logger
  
  # Modified mount function for joining existing games
  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Logger.info("Mounting with ID: #{id}")
    
    if connected?(socket) do
      # Subscribe to PubSub updates for this game
      Chess.PubSub.subscribe("game:#{id}")
      
      game_state = Chess.GameState.get_game(id)
      Logger.info("Game state for #{id}: #{inspect(game_state)}")
      
      case game_state do
        nil -> 
          Logger.info("No game found for ID: #{id}")
          {:ok, socket |> redirect(to: "/play")}
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
                  |> assign(:board, Chess.Board2.standard())
                  |> assign(:turn, :white)
                  |> assign(:selected_square, nil)
                  |> assign(:valid_moves, [])
                  |> assign(:player_color, :black)}
    end
  end

  # Modified mount function for creating new games or rejoining as host
  @impl true
  def mount(params, _session, socket) do
    Logger.info("Mounting without ID params: #{inspect(params)}")
    
    if connected?(socket) do
      case params do
        # New case to handle existing game ID in params
        %{"game" => game_id} ->
          Chess.PubSub.subscribe("game:#{game_id}")
          case Chess.GameState.get_game(game_id) do
            nil ->
              create_new_game(socket)
            game_state ->
              {:ok, socket |> assign(:game, game_id)
                          |> assign(:board, game_state.board)
                          |> assign(:turn, game_state.turn)
                          |> assign(:selected_square, nil)
                          |> assign(:valid_moves, [])
                          |> assign(:player_color, :white)}
          end
        _ ->
          create_new_game(socket)
      end
    else
      {:ok, socket |> assign(:game, nil)
                  |> assign(:board, Chess.Board2.standard())
                  |> assign(:turn, :white)
                  |> assign(:selected_square, nil)
                  |> assign(:valid_moves, [])
                  |> assign(:player_color, :white)}
    end
  end

  # New helper function to create games
  defp create_new_game(socket) do
    game_id = generate_game_id()
    Logger.info("Generated new game ID: #{game_id}")
    
    # Subscribe to PubSub updates for the new game
    Chess.PubSub.subscribe("game:#{game_id}")
    
    initial_state = %{
      board: Chess.Board2.standard(),
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
  end

  defp generate_game_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)
  end

  # Render function remains unchanged
  @impl true
  def render(assigns) do
    if assigns[:board] == nil do
      ~H"""
      <center> <h2> Connecting to chess game... </h2> </center>
      """
    else
      ~H"""
      <div class="container mx-auto px-4 py-8">
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
          <%= for row <- 0..23 do %>
            <div class="row">
              <%= for col <- 0..23 do %>
                <%
                  piece = Map.get(@board.cells, {row, col})
                  is_selected = @selected_square == {row, col}
                  is_valid_move = {row, col} in @valid_moves
                  square_color = if rem(row + col, 2) == 0, do: "white", else: "black"
                  piece_data = if piece, do: Chess.Piece.glyphs()[piece.color][piece.type]
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
        <!-- Timer display -->
        <div id="timer-display" class="text-center mt-4 text-xl font-bold">
          Time elapsed: 0 seconds
        </div>

        <!-- Inline JavaScript for Timer -->
        <script>
          (function startTimer() {
            let seconds = 0;
            const timerElement = document.getElementById("timer-display");

            if (timerElement) {
              setInterval(() => {
                seconds += 1;
                timerElement.textContent = `Time elapsed: ${seconds} seconds`;
              }, 1000);
            }
          })();
        </script>
      </div>
      """
    end
  end

  # Modified handle_event for select_square to use PubSub
  @impl true
  def handle_event("select_square", %{"row" => row, "col" => col}, socket) do
    if socket.assigns.turn == socket.assigns.player_color do
      position = {String.to_integer(row), String.to_integer(col)}
      Logger.info("Square clicked at position: #{inspect(position)}")
      
      cond do
        socket.assigns.selected_square != nil ->
          from = socket.assigns.selected_square
          Logger.info("Moving from: #{inspect(from)} to: #{inspect(position)}")
          
          if position in Chess.Piece.possible_moves(socket.assigns.board, socket.assigns.board.cells[from], from) do
            new_board = Chess.Board2.make_move(socket.assigns.board, position, from)
            new_turn = if(socket.assigns.turn == :white, do: :black, else: :white)
            
            # Update game state and broadcast move
            if socket.assigns.game do
              Chess.GameState.create_game(socket.assigns.game, %{
                board: new_board,
                turn: new_turn
              })
              
              # Broadcast move using PubSub instead of WebSocket
              Chess.PubSub.broadcast("game:#{socket.assigns.game}", {:move_made, %{
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
                valid_moves = Chess.Piece.possible_moves(socket.assigns.board, piece, position)
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

  # New handle_info callback to process PubSub messages
  @impl true
  def handle_info({:move_made, %{board: new_board, turn: new_turn}}, socket) do
    Logger.info("Received move broadcast")
    {:noreply, socket
      |> assign(:board, new_board)
      |> assign(:turn, new_turn)
      |> assign(:selected_square, nil)
      |> assign(:valid_moves, [])}
  end
end

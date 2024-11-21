defmodule ChessWeb.Live.War do
  use ChessWeb, :live_view
  require Logger
  
  @pubsub_topic_prefix "war:"

  @initial_state %{board: Chess.Board.Presets.War.standard(:white, :black), turn: :white}

  @impl true
  def mount(%{"id" => id}, _session, socket) do # Entry point for existing games
    Logger.info "Mounting game with id #{id}"

    if connected?(socket) do
      if game_state = Chess.GameState.get_game(id) do
	# Subscribe to PubSub for game updates
	Chess.PubSub.subscribe("#{@pubsub_topic_prefix}#{id}")
	
	Logger.info("Found existing game (#{id})")
	{:ok, socket |> assign(:game, id)
                     |> assign(:board, game_state.board)
                     |> assign(:turn, :black)
                     |> assign(:selected_square, nil)
                     |> assign(:valid_moves, [])
                     |> assign(:player_color, :black)}
      else
	Logger.info "Unknown game ID"
	{:ok, socket |> redirect(to: "/play") }
      end
    else
      Logger.info "Not connected with ID"
      {:ok, socket}
    end
  end

  @impl true
  def mount(_params, _session, socket) do # Entry point for new games
    Logger.info "Mounting new game"
    
    if connected?(socket) do
      game_id = generate_game_id()
      Logger.info "Generated new game ID: #{game_id}"
      
      # Subscribe to PubSub for game updates and save initial state
      Chess.PubSub.subscribe("#{@pubsub_topic_prefix}#{game_id}")
      Chess.GameState.create_game(game_id, @initial_state)
      
      # Return a new game
      {:ok, socket |> assign(:game, game_id)
                   |> assign(:board, @initial_state.board)
                   |> assign(:turn, @initial_state.turn)
                   |> assign(:selected_square, nil)
                   |> assign(:valid_moves, [])
                   |> assign(:player_color, :white)}
    else
      Logger.info "Not connected no ID"
      {:ok, socket}
    end
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
      position = [String.to_integer(row), String.to_integer(col)]
      Logger.info("Square clicked at position: #{inspect(position)}")
      
      cond do
        socket.assigns.selected_square != nil ->
          from = socket.assigns.selected_square
          Logger.info("Moving from: #{inspect(from)} to: #{inspect(position)}")
          
          if position in Chess.Piece.Moves.get(socket.assigns.board, socket.assigns.board.cells[from], from) do
            new_board = Chess.Board.make_move(socket.assigns.board, position, from)
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
              if piece.owner == socket.assigns.turn do
                Logger.info("Selected piece: #{piece.owner} #{piece.type}")
                valid_moves = Chess.Piece.Moves.get(socket.assigns.board, piece, position)
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

  defp generate_game_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)
  end
end

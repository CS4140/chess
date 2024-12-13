defmodule ChessWeb.Live.Observe do
  use ChessWeb, :live_view
  require Logger

  # Define PubSub topic prefix for regular chess games
  @pubsub_topic_prefix "game:"

  @initial_state %{board: Chess.Board.Presets.standard(:white, :black), turn: :white}

  @impl true
  def mount(%{"id" => id}, _session, socket) do # Entry point for existing games
    #Logger.info "Observing game with id #{id}"

    if connected?(socket) do
      if game_state = Chess.GameState.get_game(id) do
	# Subscribe to PubSub for game updates
	Chess.PubSub.subscribe("#{@pubsub_topic_prefix}#{id}")

	{:ok, socket |> assign(:game, id)
                     |> assign(:board, game_state.board)
                     |> assign(:turn, game_state.turn)
	             |> assign(:result, nil)}
      else
	#Logger.info "Cannot observe unknown game ID"
	{:ok, socket}
      end
    else
      #Logger.info "Observer not connected"
      {:ok, socket}
    end
  end

  @impl true
  def mount(_params, _session, socket) do # Entry point for new games
    #Logger.info "Refusing to observe a game with no ID"
    {:ok, socket}
  end

  # Render function remains unchanged
  @impl true
  def render(assigns) do
    cond do
      assigns[:game] == nil ->
~H"""
<center> <h2> You did not enter a game ID, or the one you did enter does not exist </h2> </center>
"""
      assigns[:board] == nil ->
~H"""
<center> <h2> Connecting to chess game... </h2> </center>
"""
      true ->
~H"""
<div class="">
    <div class="text-center mb-4">
	<div>Game ID: <%= @game %></div>
	<div>You are observing</div>
    </div>

    <%= if @result != nil do %>
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
        <div class="bg-white p-8 rounded-lg shadow-lg text-center">
            <h2 class="text-2xl font-bold mb-4"><%= @result %></h2>
            <a href="/" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                Return to main menu
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
	    square_color = if rem(row + col, 2) == 0, do: "white", else: "black"
	    piece_data = if piece, do: Chess.Piece.glyphs()[piece.owner][piece.type]
	    %>
	    <div class={"square #{square_color}"}
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
</div>
"""
    end
  end

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
end


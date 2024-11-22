defmodule ChessWeb.GameLive do
  use ChessWeb, :live_view

  def mount(%{"game_id" => game_id}, _session, socket) do
    # Load game state using the game_id
    # This can be a game state stored in the database or in memory
    game_state = Chess.GameServer.get_game_state(game_id)

    # Assign the game state and game_id to the socket
    {:ok, assign(socket, game_id: game_id, game_state: game_state)}
  end

  def handle_event("move", %{"from" => from, "to" => to}, socket) do
    # Handle a move event (e.g., move a piece)
    game_state = Chess.GameServer.make_move(socket.assigns.game_id, from, to)

    # Update the game state in the socket
    {:noreply, assign(socket, game_state: game_state)}
  end

  # Optionally, handle other game events like resign, draw, etc.
end

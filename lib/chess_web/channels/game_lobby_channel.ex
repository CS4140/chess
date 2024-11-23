defmodule ChessWeb.GameLobbyChannel do
  use Phoenix.Channel

  def join("game:lobby", _params, socket) do
    {:ok, socket}
  end

  def handle_in("join_game", %{"player_id" => player_id}, socket) do
    case Chess.Matchmaker.join_queue(player_id) do
      :waiting ->
        # Inform the player they are waiting for an opponent
        push(socket, "status", %{message: "Waiting for an opponent..."})
        {:noreply, socket}

      {:matched, opponent_id, game_id} ->
        # Notify both players of the match and the game ID
        ChessWeb.Endpoint.broadcast!("game:lobby", "match_found", %{
          game_id: game_id,
          player1: player_id,
          player2: opponent_id
        })

        {:noreply, socket}
    end
  end

  def handle_in("leave_game", %{"player_id" => player_id}, socket) do
    Chess.Matchmaker.leave_queue(player_id)
    {:noreply, socket}
  end
end

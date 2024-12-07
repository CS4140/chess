# lib/chess_web/channels/game_channel.ex
defmodule ChessWeb.GameChannel do
  use Phoenix.Channel
  require Logger

  def join("game:" <> game_id, _params, socket) do
    Logger.info("Player joining game: #{game_id}")
    {:ok, assign(socket, :game_id, game_id)}
  end

  def join("crazy_game:" <> game_id, _params, socket) do
    Logger.info("Player joining crazy game: #{game_id}")
    {:ok, assign(socket, :game_id, game_id)}
  end

  def handle_in("move_made", %{"from" => from, "to" => to}, socket) do
    Logger.info("Broadcasting move in game #{socket.assigns.game_id}")
    broadcast_from!(socket, "move_made", %{from: from, to: to})
    {:noreply, socket}
  end
end

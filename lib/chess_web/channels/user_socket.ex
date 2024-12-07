defmodule ChessWeb.UserSocket do
  use Phoenix.Socket

  channel "game:*", ChessWeb.GameChannel
  channel "crazy_game:*", ChessWeb.GameChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end

defmodule ChessWeb.Live.Prepare do
  use ChessWeb, :live_view
  import Ecto.Query
  require Logger
  alias Chess.{Board, Repo}
  alias Phoenix.LiveView.Socket

  # Color to display piece inventory as. This would be an attribute (@) if it
  # was accessable via the HEEx template in the render function
  defp piececolor(), do: :black

  @impl true
  def mount(_, session, socket) do
    if user = current_user(session) do
      if (connected?(socket)) do
	# Logger.info "ChessWeb.Live.Prepare.mount(): connected"
	
	{:ok, socket |> assign(:board, Chess.Piece.Inventory.get_board(Board.Presets.emptysmall, user))
                     |> assign(:current_user, user.id)
                     |> assign(:inventory, Chess.Piece.Inventory.get_floating(user))}
      else
	# Logger.info "ChessWeb.Live.Prepare.mount(): waiting to connect"
	{:ok, socket |> assign(:current_user, user)}
      end
    else
      # Logger.info "ChessWeb.Live.Prepare.mount(): not logged in"
      {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    cond do
      assigns[:current_user] == nil ->
~H"""
<center>
    <h2>
        You must be logged in to prepare your pieces
    </h2>
</center>
"""
      assigns[:board] == nil ->
~H"""
<center>
    <h2>
	Connecting...
    </h2>
</center>
"""
      true ->
~H"""
<%= if assigns[:space] do %>
    <p>Space: <%= Enum.join(assigns[:space], ",") %></p>
<% else %>
    <p>No space selected</p>
<% end %>
<br>
<%= if assigns[:piece] do %>
    <p>Piece: <%= assigns[:piece] %></p>
<% else %>
    <p>No piece selected</p>
<% end %>
<br>

<label for="inventory">Available pieces:</label>
<table id="inventory" class="square cursor-pointer">
    <tr>
        <td> <%= "\u00A0" %> </td>
        <%= for {p, i} <- Enum.with_index(assigns[:inventory]) do %>
            <td phx-click="piece clicked"
	        phx-value-i={i}>
	        <%= Chess.Piece.glyphs()[piececolor()][p.type] %>
	    </td>
        <% end %>
    </tr>
</table>

<table id="board" class="square cursor-pointer" phx-click="clear selection">
    <%= for row <- 0..assigns[:board].width - 1 do %>
    <tr>
        <%= for col <- 0..assigns[:board].height - 1 do %>
        <td phx-click="space clicked"
	    phx-value-row={row}
	    phx-value-col={col}
	    class="w-[1em] border-2 border-black">
	        <%=
                if piece = assigns[:board].cells[[row, col]] do
                    Chess.Piece.glyphs()[piececolor()][piece.type]
                else	
            "\u00A0"
                end
                %>
        </td>
        <% end %>
    </tr>
    <% end %>
</table>
<center>
    <button type="button" phx-value-current-user={@current_user} phx-click="save">
	Save
    </button>
</center>
"""
    end
  end

  @impl true
  def handle_event("piece clicked", %{"i" => i}, socket) do
    { :noreply, socket |> assign(:piece, String.to_integer(i)) |> interpret_event() }
  end

  @impl true
  def handle_event("space clicked", %{"row" => row, "col" => col}, socket) do
    position = [String.to_integer(row), String.to_integer(col)]
    { :noreply, socket |> assign(:space, position) |> interpret_event() }
  end

  def handle_event("clear selection", _, socket) do
    { :noreply, socket |> assign(:piece, nil) |> assign(:space, nil) }
  end

  # This should use a changeset
  def handle_event("save", %{"current-user" => id},
                   socket = %Socket{assigns: %{board: board, inventory: inventory}}) do
    Repo.delete_all(from p in Chess.Piece, where: p.owner_id == ^id);

    Enum.each(inventory, &Repo.insert/1);

    Enum.filter(board.cells, fn {_, piece} -> piece != nil end)
    |> Enum.map(fn {space, piece} -> %{ piece | origin: space, owner_id: String.to_integer(id) } end)
    |> Enum.each(&Repo.insert/1);

    { :noreply, socket |> assign(:piece, nil) |> assign(:space, nil) |> redirect(to: "/prepare") }
  end

  def interpret_event(socket = %Socket{assigns: assigns = %{
					  board: board, inventory: inventory, space: space
					}}) when space != nil do
    piece = assigns[:piece]

    cond do
      piece == nil && board.cells[space] == nil ->
	# Logger.info "piece not selected and empty space"
	socket
      piece == nil && board.cells[space] ->
	# Logger.info "piece not selected and space full"
	socket |> assign(:space, nil)
	|> assign(:board, Board.set_piece(board, nil, space))
	|> assign(:inventory, [ %{board.cells[space] | origin: nil} | inventory ])
	#|> assign(:piece, 0)
      board.cells[space] == nil ->
	# Logger.info "piece selected and empty space"
	socket |> assign(:piece, nil) |> assign(:space, nil)
	|> assign(:inventory, List.delete_at(inventory, piece))
	|> assign(:board, Board.set_piece(board, Enum.at(inventory, piece), space))
      board.cells[space] ->
	# Logger.info "piece selected and space full"
	socket |> assign(:piece, nil) |> assign(:space, nil)
	|> assign(:board, Board.set_piece(board, Enum.at(inventory, piece), space))
	|> assign(:inventory, [ board.cells[space] | List.delete_at(inventory, piece) ])
    end
  end

  # If there was no selected space, do nothing
  def interpret_event(socket), do: socket

  defp current_user(session) do
    case session["user_token"] do
      nil ->
	nil
      t ->
	Chess.Accounts.get_user_by_session_token(t)
    end
  end
end

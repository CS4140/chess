defmodule ChessWeb.Live.Prepare do
  use ChessWeb, :live_view
  require Logger

  # Color to display piece inventory as. This would be an attribute (@) if it
  # was accessable via the HEEx template in render(0
  defp piececolor(), do: :black

  @impl true
  def mount(_, session, socket) do
    if user = current_user(session) do
      if (connected?(socket)) do
	Logger.info "ChessWeb.Live.Prepare.mount(): connected"
	
	{:ok, socket |> assign(:board, Chess.Board.Presets.emptysmall)
                     |> assign(:current_user, user) # why doesn't the :browser pipeline do this?
                     |> assign(:inventory, Chess.Piece.Inventory.get(user))}
      else
	Logger.info "ChessWeb.Live.Prepare.mount(): waiting to connect"
	{:ok, socket |> assign(:current_user, user)}
      end
    else
      Logger.info "ChessWeb.Live.Prepare.mount(): not logged in"
      {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    IO.inspect assigns[:board], label: "render board"

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
        <%= for {p, i} <- Enum.with_index(assigns[:inventory]) do %>
            <td phx-click="click_piece"
	        phx-value-i={i}>
	        <%= Chess.Piece.glyphs()[piececolor()][p.type] %>
	    </td>
        <% end %>
    </tr>
</table>

<table id="board" class="square cursor-pointer">
    <%= for row <- 0..assigns[:board].width - 1 do %>
    <tr>
        <%= for col <- 0..assigns[:board].height - 1 do %>
        <td phx-click="click_space"
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
"""
    end
  end

  @impl true
  def handle_event("click_piece", %{"i" => i}, socket) do
    { :noreply, socket |> assign(:piece, String.to_integer(i)) |> interpret_event() }
  end

  @impl true
  def handle_event("click_space", %{"row" => row, "col" => col}, socket) do
    position = [String.to_integer(row), String.to_integer(col)]
    { :noreply, socket |> assign(:space, position) |> interpret_event() }
  end

  def interpret_event(socket = %Phoenix.LiveView.Socket{assigns: %{board: board}}) do
    piecei = socket.assigns[:piece]
    space = socket.assigns[:space]

    if space == nil or (piecei == nil and board.cells[space] == nil) do
      socket
    else
      socket |> assign(:space, nil) |> assign(:piece, nil) |> assign(:board, 
	cond do
	  piecei && board.cells[space] == nil ->
	    IO.inspect board, label: "board in"
	    #IO.puts "piece selected and space not taken"
	    #IO.inspect space, label: "moving to"
	    #IO.inspect board.cells[space], label: "kicking out a"
	    #IO.inspect Enum.at(socket.assigns[:inventory], piecei), label: "it is a"
	    n = Chess.Board.set_piece(board, Enum.at(socket.assigns[:inventory], piecei), space)
	    IO.inspect n, label: "board out"
	    n
	  piecei == nil && board.cells[space] ->
	    IO.puts("piece not selected and space full");
	    board
	  piecei && board.cells[space] ->
	    IO.puts("piece selected and space taken");
	    board
	  true ->
	    IO.puts("doing nothing (probably no piece and no space selected)");
	    board
	end)
    end
  end

  # If there was no board or selected space, do nothing
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

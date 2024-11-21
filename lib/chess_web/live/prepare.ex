defmodule ChessWeb.Live.Prepare do
  use ChessWeb, :live_view

  defp piece_inventory(o) do # replace this function in the future
    [%Chess.Piece{type: :pawn, owner: o},
     %Chess.Piece{type: :pawn, owner: o},
     %Chess.Piece{type: :pawn, owner: o},
     %Chess.Piece{type: :pawn, owner: o},
     %Chess.Piece{type: :pawn, owner: o},
     %Chess.Piece{type: :pawn, owner: o},
     %Chess.Piece{type: :pawn, owner: o},
     %Chess.Piece{type: :pawn, owner: o},

     %Chess.Piece{type: :rook, owner: o},
     %Chess.Piece{type: :knight, owner: o},
     %Chess.Piece{type: :bishop, owner: o},
     %Chess.Piece{type: :queen, owner: o},
     %Chess.Piece{type: :king, owner: o},
     %Chess.Piece{type: :bishop, owner: o},
     %Chess.Piece{type: :knight, owner: o},
     %Chess.Piece{type: :rook, owner: o}]
  end

  @impl true
  def mount(_, session, socket) do
    if (connected?(socket)) do
      # TODO: fetch game from server with id
      IO.puts "ChessWeb.Live.Prepare.mount(): connected"
      user = current_user(session)
      {:ok, socket |> assign(:board, Chess.Board.Presets.empty(8, 8))
                   |> assign(:current_user, user) # why doesn't the :browser pipeline do this?
                   |> assign(:inventory, piece_inventory(:black))}
    else
      IO.puts "ChessWeb.Live.Prepare.mount(): waiting to connect"
      {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
#    IO.inspect assigns[:board];

    if assigns[:board]  == nil do
~H"""
<center><h2>Connecting... </h2></center>
"""
    else
~H"""
<%= if assigns[:space] do %>
    <p>Space: <%= Enum.join(Tuple.to_list(assigns[:space]), ",") %></p>
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
<%= if assigns[:current_user] do %>
    <p>You are: <%= assigns[:current_user].email %></p>
<% else %>
    <p>Not logged in</p>
<% end %>


<label for="inventory">Available pieces:</label>
<table id="inventory" class="square cursor-pointer">
    <tr>
        <%= for {p, i} <- Enum.with_index(assigns[:inventory]) do %>
            <td phx-click="click_piece"
	        phx-value-i={i}>
	        <%= Chess.Piece.glyphs()[p.owner][p.type] %>
	    </td>
        <% end %>
    </tr>
</table>

<table id="board" class="square cursor-pointer">
    <%= for row <- 0..7 do %>
    <tr>
        <%= for col <- 0..7 do %>
        <td phx-click="click_space"
	    phx-value-row={row}
	    phx-value-col={col}
	    class="w-[1em] border-2 border-black">
	        <%=
                if piece = assigns[:board].cells[{col, row}] do
                    Chess.Piece.glyphs()[piece.owner][piece.type]
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
    IO.inspect {i}, label: "handle_event(i)"

    # a piece was clicked
    # write down the selected piece
    # was a space selected?
    #     if so, put that piece at the selected space and mark this piece as used (remove it from inventory)

    { :noreply, socket |> assign(:piece, i) }
  end

  @impl true
  def handle_event("click_space", %{"row" => row, "col" => col}, socket) do
    IO.inspect {row, col}, label: "handle_event(click_space)"

    # a space was clicked
    # write down the selected space
    # space free/piece selected -> put the selected piece at the selected square, remove from inventory
    # space taken/piece selected -> swap the selected piece with the piece at the selected square
    # space free/piece not selected -> don't do anything
    # space taken/piece not selected -> return piece to inventory

    { :noreply, socket |> assign(:space, {row, col}) }
  end

  defp current_user(session) do
    case session["user_token"] do
      nil ->
	nil
      t ->
	Chess.Accounts.get_user_by_session_token(t)
    end
  end
end

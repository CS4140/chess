defmodule ChessWeb.Live.Auto do
  use ChessWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if (connected?(socket)) do
      # TODO: fetch game from server with id
      IO.puts "Connected with ID"
      {:ok, socket |> assign(:game, id)
                   |> assign(:board, Chess.Board.Presets.testboard())}
    else
      IO.puts "Not connected with ID"
      {:ok, socket}
    end
  end

  @impl true
  def mount(_, _session, socket) do
    if (connected?(socket)) do
      # TODO: fetch game from server with id
      IO.puts "Connected no ID"
      {:ok, socket |> assign(:game, nil)
                   |> assign(:board, Chess.Board.Presets.testboard())}
    else
      IO.puts "Not connected no ID"
      {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    if assigns[:board]  == nil do
~H"""
<center> <h2> Connecting to chess game... </h2> </center>
"""
    else
~H"""
<div class="board">
 <%= for x <- 0..7 do %>
  <div class="row">
   <%= for y <- 0..7 do %>
   <button class="square" phx-click="click_square" phx-value-row={y}>
    <%=
     piece = assigns[:board].cells[{x, y}]
     unless piece == nil do
       Chess.Piece.glyphs()[piece.color][piece.type]
     end
     %>
    </button>
   <% end %>
  </div>
 <% end %>
</div>
"""
    end
  end

  defp random_movable_piece(board = %Chess.Board{cells: cells}) do
    loc = Map.keys(cells) |> Enum.random()

    if cells[loc] != nil do
      moves = Chess.Piece.possible_moves(board, cells[loc], loc)
      if length(moves) > 1 do
	{loc, moves -- [loc]}
      else
	random_movable_piece(board)
      end
    else
      random_movable_piece(board)
    end
  end

  @impl true
  def handle_event(_, _, socket) do
    board = socket.assigns[:board]
#    IO.inspect board, label: "show() board"
#    IO.inspect random_movable_piece(board), label: "piece and moves"

    {from, moves} = random_movable_piece(board)
    to = Enum.random(moves)
#    IO.inspect from, label: "from"
#    IO.inspect to, label: "to"
#    IO.inspect board.cells[from], label: "a"
#    IO.inspect board, label: "before", limit: :infinity
    board = Chess.Board.make_move(board, to, from)
#    IO.inspect board, label: "after", limit: :infinity

    {:noreply, socket |> assign(:board, board)}
  end
end

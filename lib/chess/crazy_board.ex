# lib/chess/crazy_board.ex
defmodule Chess.CrazyBoard do
  defstruct width: nil,
            height: nil,
            cells: %{} # {coordinate} => %Chess.CrazyPiece{}

  def make_move(board = %Chess.CrazyBoard{cells: cells}, to, from) do
    if to == from do
      board
    else
      %{board | cells: %{cells | to => board.cells[from], from => nil}}
    end
  end

  def standard do
    %Chess.CrazyBoard{
      width: 8, height: 8, cells: %{
        # Black pieces back row (column 0)
        {0, 0} => %Chess.CrazyPiece{type: :dragon, color: :black},
        {1, 0} => %Chess.CrazyPiece{type: :ninja, color: :black},
        {2, 0} => %Chess.CrazyPiece{type: :phoenix, color: :black},
        {3, 0} => %Chess.CrazyPiece{type: :wizard, color: :black},
        {4, 0} => %Chess.CrazyPiece{type: :king, color: :black},
        {5, 0} => %Chess.CrazyPiece{type: :phoenix, color: :black},
        {6, 0} => %Chess.CrazyPiece{type: :ninja, color: :black},
        {7, 0} => %Chess.CrazyPiece{type: :dragon, color: :black},

        # Black pawns (column 1)
        {0, 1} => %Chess.CrazyPiece{type: :pawn, color: :black},
        {1, 1} => %Chess.CrazyPiece{type: :pawn, color: :black},
        {2, 1} => %Chess.CrazyPiece{type: :pawn, color: :black},
        {3, 1} => %Chess.CrazyPiece{type: :pawn, color: :black},
        {4, 1} => %Chess.CrazyPiece{type: :pawn, color: :black},
        {5, 1} => %Chess.CrazyPiece{type: :pawn, color: :black},
        {6, 1} => %Chess.CrazyPiece{type: :pawn, color: :black},
        {7, 1} => %Chess.CrazyPiece{type: :pawn, color: :black},

        # Empty middle squares
        {0, 2} => nil, {1, 2} => nil, {2, 2} => nil, {3, 2} => nil,
        {4, 2} => nil, {5, 2} => nil, {6, 2} => nil, {7, 2} => nil,

        {0, 3} => nil, {1, 3} => nil, {2, 3} => nil, {3, 3} => nil,
        {4, 3} => nil, {5, 3} => nil, {6, 3} => nil, {7, 3} => nil,

        {0, 4} => nil, {1, 4} => nil, {2, 4} => nil, {3, 4} => nil,
        {4, 4} => nil, {5, 4} => nil, {6, 4} => nil, {7, 4} => nil,

        {0, 5} => nil, {1, 5} => nil, {2, 5} => nil, {3, 5} => nil,
        {4, 5} => nil, {5, 5} => nil, {6, 5} => nil, {7, 5} => nil,

        # White pawns (column 6)
        {0, 6} => %Chess.CrazyPiece{type: :pawn, color: :white},
        {1, 6} => %Chess.CrazyPiece{type: :pawn, color: :white},
        {2, 6} => %Chess.CrazyPiece{type: :pawn, color: :white},
        {3, 6} => %Chess.CrazyPiece{type: :pawn, color: :white},
        {4, 6} => %Chess.CrazyPiece{type: :pawn, color: :white},
        {5, 6} => %Chess.CrazyPiece{type: :pawn, color: :white},
        {6, 6} => %Chess.CrazyPiece{type: :pawn, color: :white},
        {7, 6} => %Chess.CrazyPiece{type: :pawn, color: :white},

        # White pieces back row (column 7)
        {0, 7} => %Chess.CrazyPiece{type: :dragon, color: :white},
        {1, 7} => %Chess.CrazyPiece{type: :ninja, color: :white},
        {2, 7} => %Chess.CrazyPiece{type: :phoenix, color: :white},
        {3, 7} => %Chess.CrazyPiece{type: :wizard, color: :white},
        {4, 7} => %Chess.CrazyPiece{type: :king, color: :white},
        {5, 7} => %Chess.CrazyPiece{type: :phoenix, color: :white},
        {6, 7} => %Chess.CrazyPiece{type: :ninja, color: :white},
        {7, 7} => %Chess.CrazyPiece{type: :dragon, color: :white},
      }
    }
  end

  # Add a test board setup for debugging
  def testboard do
    %Chess.CrazyBoard{
      width: 8, height: 8, cells: %{
        # Just a few pieces for testing
        {0, 0} => %Chess.CrazyPiece{type: :dragon, color: :black},
        {4, 0} => %Chess.CrazyPiece{type: :king, color: :black},
        {7, 0} => %Chess.CrazyPiece{type: :wizard, color: :black},
        
        {0, 1} => %Chess.CrazyPiece{type: :pawn, color: :black},
        {4, 1} => %Chess.CrazyPiece{type: :phoenix, color: :black},
        {7, 1} => %Chess.CrazyPiece{type: :ninja, color: :black},

        {3, 3} => %Chess.CrazyPiece{type: :dragon, color: :white},
        {4, 4} => %Chess.CrazyPiece{type: :wizard, color: :white},
        
        {0, 6} => %Chess.CrazyPiece{type: :pawn, color: :white},
        {4, 6} => %Chess.CrazyPiece{type: :phoenix, color: :white},
        {7, 6} => %Chess.CrazyPiece{type: :ninja, color: :white},
        
        {0, 7} => %Chess.CrazyPiece{type: :dragon, color: :white},
        {4, 7} => %Chess.CrazyPiece{type: :king, color: :white},
        {7, 7} => %Chess.CrazyPiece{type: :wizard, color: :white},
      }
    }
  end
end

defmodule Chess.Board.Presets.Crazy do
  def standard(p1, p2) do
    %Chess.Board{
      width: 8, height: 8, cells: %{
        # Black pieces back row (column 0)
        [0, 0] => %Chess.Piece{type: :dragon, owner: p2},
        [1, 0] => %Chess.Piece{type: :ninja, owner: p2},
        [2, 0] => %Chess.Piece{type: :phoenix, owner: p2},
        [3, 0] => %Chess.Piece{type: :wizard, origin: [3, 0], owner: p2},
        [4, 0] => %Chess.Piece{type: :king, owner: p2},
        [5, 0] => %Chess.Piece{type: :phoenix, owner: p2},
        [6, 0] => %Chess.Piece{type: :ninja, owner: p2},
        [7, 0] => %Chess.Piece{type: :dragon, owner: p2},

        # Black pawns (column 1)
        [0, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [1, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [2, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [3, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [4, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [5, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [6, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [7, 1] => %Chess.Piece{type: :pawn, owner: p2},

        # Empty middle squares
        [0, 2] => nil, [1, 2] => nil, [2, 2] => nil, [3, 2] => nil,
        [4, 2] => nil, [5, 2] => nil, [6, 2] => nil, [7, 2] => nil,

        [0, 3] => nil, [1, 3] => nil, [2, 3] => nil, [3, 3] => nil,
        [4, 3] => nil, [5, 3] => nil, [6, 3] => nil, [7, 3] => nil,

        [0, 4] => nil, [1, 4] => nil, [2, 4] => nil, [3, 4] => nil,
        [4, 4] => nil, [5, 4] => nil, [6, 4] => nil, [7, 4] => nil,

        [0, 5] => nil, [1, 5] => nil, [2, 5] => nil, [3, 5] => nil,
        [4, 5] => nil, [5, 5] => nil, [6, 5] => nil, [7, 5] => nil,

        # White pawns (column 6)
        [0, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [1, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [2, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [3, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [4, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [5, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [6, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [7, 6] => %Chess.Piece{type: :pawn, owner: p1},

        # White pieces back row (column 7)
        [0, 7] => %Chess.Piece{type: :dragon, owner: p1},
        [1, 7] => %Chess.Piece{type: :ninja, owner: p1},
        [2, 7] => %Chess.Piece{type: :phoenix, owner: p1},
        [3, 7] => %Chess.Piece{type: :wizard, origin: [3, 7], owner: p1},
        [4, 7] => %Chess.Piece{type: :king, owner: p1},
        [5, 7] => %Chess.Piece{type: :phoenix, owner: p1},
        [6, 7] => %Chess.Piece{type: :ninja, owner: p1},
        [7, 7] => %Chess.Piece{type: :dragon, owner: p1},
      }
    }
  end

  def testboard(p1, p2) do
    %Chess.Board{
      width: 8, height: 8, cells: %{
        # Test layout with fewer pieces for debugging
        [0, 0] => %Chess.Piece{type: :dragon, owner: p2},
        [4, 0] => %Chess.Piece{type: :king, owner: p2},
        [7, 0] => %Chess.Piece{type: :wizard, origin: [7, 0], owner: p2},
        
        [0, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [4, 1] => %Chess.Piece{type: :phoenix, owner: p2},
        [7, 1] => %Chess.Piece{type: :ninja, owner: p2},

        [3, 3] => %Chess.Piece{type: :dragon, owner: p1},
        [4, 4] => %Chess.Piece{type: :wizard, origin: [4, 4], owner: p1},
        
        [0, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [4, 6] => %Chess.Piece{type: :phoenix, owner: p1},
        [7, 6] => %Chess.Piece{type: :ninja, owner: p1},
        
        [0, 7] => %Chess.Piece{type: :dragon, owner: p1},
        [4, 7] => %Chess.Piece{type: :king, owner: p1},
        [7, 7] => %Chess.Piece{type: :wizard, origin: [7, 7], owner: p1},

        # Fill remaining squares with nil
        [1, 0] => nil, [2, 0] => nil, [3, 0] => nil, [5, 0] => nil, [6, 0] => nil,
        [1, 1] => nil, [2, 1] => nil, [3, 1] => nil, [5, 1] => nil, [6, 1] => nil,
        [0, 2] => nil, [1, 2] => nil, [2, 2] => nil, [3, 2] => nil, [4, 2] => nil, [5, 2] => nil, [6, 2] => nil, [7, 2] => nil,
        [0, 3] => nil, [1, 3] => nil, [2, 3] => nil, [4, 3] => nil, [5, 3] => nil, [6, 3] => nil, [7, 3] => nil,
        [0, 4] => nil, [1, 4] => nil, [2, 4] => nil, [3, 4] => nil, [5, 4] => nil, [6, 4] => nil, [7, 4] => nil,
        [0, 5] => nil, [1, 5] => nil, [2, 5] => nil, [3, 5] => nil, [4, 5] => nil, [5, 5] => nil, [6, 5] => nil, [7, 5] => nil,
        [1, 6] => nil, [2, 6] => nil, [3, 6] => nil, [5, 6] => nil, [6, 6] => nil,
        [1, 7] => nil, [2, 7] => nil, [3, 7] => nil, [5, 7] => nil, [6, 7] => nil
      }
    }
  end
end

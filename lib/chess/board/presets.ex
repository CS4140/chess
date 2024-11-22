defmodule Chess.Board.Presets do
  def empty(cols, rows) do
    %Chess.Board{
      width: cols, height: rows, cells:
      Map.new(
	List.flatten(
	  for row <- 0..rows, do: (for col <- 0..cols, do: [row, col])
	),
	fn p -> {p, nil} end)
    }
  end

  def emptysmall do
    %Chess.Board{
      width: 4, height: 4, cells: %{
	[0, 0] => nil,
	[1, 0] => nil,
	[2, 0] => nil,
	[3, 0] => nil,
	[0, 1] => nil,
	[1, 1] => nil,
	[2, 1] => nil,
	[3, 1] => nil,
	[0, 2] => nil,
	[1, 2] => nil,
	[2, 2] => nil,
	[3, 2] => nil,
	[0, 3] => nil,
	[1, 3] => nil,
	[2, 3] => nil,
	[3, 3] => nil
      }
    }
  end

  def standard(p1, p2) do
    %Chess.Board{
      width: 8, height: 8, cells: %{
        [0, 0] => %Chess.Piece{type: :rook, owner: p2},
        [1, 0] => %Chess.Piece{type: :knight, owner: p2},
        [2, 0] => %Chess.Piece{type: :bishop, owner: p2},
        [3, 0] => %Chess.Piece{type: :queen, owner: p2},
        [4, 0] => %Chess.Piece{type: :king, owner: p2},
        [5, 0] => %Chess.Piece{type: :bishop, owner: p2},
        [6, 0] => %Chess.Piece{type: :knight, owner: p2},
        [7, 0] => %Chess.Piece{type: :rook, owner: p2},
        [0, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [1, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [2, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [3, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [4, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [5, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [6, 1] => %Chess.Piece{type: :pawn, owner: p2},
        [7, 1] => %Chess.Piece{type: :pawn, owner: p2},

        [0, 2] => nil, [1, 2] => nil, [2, 2] => nil, [3, 2] => nil, [4, 2] => nil,
        [5, 2] => nil, [6, 2] => nil, [7, 2] => nil,

        [0, 3] => nil, [1, 3] => nil, [2, 3] => nil, [3, 3] => nil, [4, 3] => nil,
        [5, 3] => nil, [6, 3] => nil, [7, 3] => nil,

        [0, 4] => nil, [1, 4] => nil, [2, 4] => nil, [3, 4] => nil, [4, 4] => nil,
        [5, 4] => nil, [6, 4] => nil, [7, 4] => nil,

        [0, 5] => nil, [1, 5] => nil, [2, 5] => nil, [3, 5] => nil, [4, 5] => nil,
        [5, 5] => nil, [6, 5] => nil, [7, 5] => nil,

        [0, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [1, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [2, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [3, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [4, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [5, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [6, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [7, 6] => %Chess.Piece{type: :pawn, owner: p1},
        [0, 7] => %Chess.Piece{type: :rook, owner: p1},
        [1, 7] => %Chess.Piece{type: :knight, owner: p1},
        [2, 7] => %Chess.Piece{type: :bishop, owner: p1},
        [3, 7] => %Chess.Piece{type: :queen, owner: p1},
        [4, 7] => %Chess.Piece{type: :king, owner: p1},
        [5, 7] => %Chess.Piece{type: :bishop, owner: p1},
        [6, 7] => %Chess.Piece{type: :knight, owner: p1},
        [7, 7] => %Chess.Piece{type: :rook, owner: p1},
      },
      capture_piles: %{black: [], white: []}  
    }
  end

 def testboard(p1, p2) do
    %Chess.Board{
      width: 8, height: 8, cells: %{
	[0, 0] => %Chess.Piece{type: :rook, owner: p2},
	[1, 0] => nil,
	[2, 0] => %Chess.Piece{type: :bishop, owner: p2},
	[3, 0] => nil,
	[4, 0] => %Chess.Piece{type: :rook, owner: p2},
	[5, 0] => nil,
	[6, 0] => %Chess.Piece{type: :king, owner: :p1},
	[7, 0] => nil,

	[0, 1] => %Chess.Piece{type: :pawn, owner: p2},
	[1, 1] => %Chess.Piece{type: :pawn, owner: p2},
	[2, 1] => nil,
	[3, 1] => nil,
	[4, 1] => %Chess.Piece{type: :queen, owner: p2},
	[5, 1] => %Chess.Piece{type: :pawn, owner: p2},
	[6, 1] => %Chess.Piece{type: :pawn, owner: p2},
	[7, 1] => %Chess.Piece{type: :pawn, owner: p2},

	[0, 2] => nil,
	[1, 2] => nil,
	[2, 2] => %Chess.Piece{type: :knight, owner: p2},
	[3, 2] => %Chess.Piece{type: :pawn, owner: p2},
	[4, 2] => nil,
	[5, 2] => %Chess.Piece{type: :knight, owner: p2},
	[6, 2] => nil,
	[7, 2] => nil,

	[0, 3] => nil,
	[1, 3] => nil,
	[2, 3] => %Chess.Piece{type: :pawn, owner: p2},
	[3, 3] => nil,
	[4, 3] => nil,
	[5, 3] => nil,
	[6, 3] => nil,
	[7, 3] => nil,

	[0, 4] => nil,
	[1, 4] => nil,
	[2, 4] => %Chess.Piece{type: :pawn, owner: p1},
	[3, 4] => %Chess.Piece{type: :pawn, owner: p1},
	[4, 4] => %Chess.Piece{type: :pawn, owner: p2},
	[5, 4] => nil,
	[6, 4] => nil,
	[7, 4] => nil,

	[0, 5] => %Chess.Piece{type: :pawn, owner: p1},
	[1, 5] => nil,
	[2, 5] => %Chess.Piece{type: :queen, owner: p1},
	[3, 5] => nil,
	[4, 5] => nil,
	[5, 5] => nil,
	[6, 5] => %Chess.Piece{type: :pawn, owner: p1},
	[7, 5] => nil,

	[0, 6] => nil,
	[1, 6] => %Chess.Piece{type: :pawn, owner: p1},
	[2, 6] => %Chess.Piece{type: :knight, owner: p1},
	[3, 6] => nil,
	[4, 6] => %Chess.Piece{type: :pawn, owner: p2},
	[5, 6] => %Chess.Piece{type: :pawn, owner: p2},
	[6, 6] => %Chess.Piece{type: :bishop, owner: p2},
	[7, 6] => %Chess.Piece{type: :pawn, owner: p2},

	[0, 7] => %Chess.Piece{type: :rook, owner: p1},
	[1, 7] => nil,
	[2, 7] => %Chess.Piece{type: :bishop, owner: p1},
	[3, 7] => nil,
	[4, 7] => nil,
	[5, 7] => %Chess.Piece{type: :rook, owner: p1},
	[6, 7] => %Chess.Piece{type: :king, owner: p1},
	[7, 7] => nil
      },
      capture_piles: %{black: [], white: []}
    };
  end
end

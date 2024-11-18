defmodule Chess.Board.Presets do
  def empty(cols, rows) do
    %Chess.Board{
      width: cols, height: rows, cells:
      Map.new(
	List.flatten(
	  for row <- 0..rows, do: (for col <- 0..cols, do: {row, col})
	),
	fn c -> {c, nil} end)
    }
  end

  def standard() do
    %Chess.Board{
      width: 8, height: 8, cells: %{
        {0, 0} => %Chess.Piece{type: :rook, color: :black},
        {1, 0} => %Chess.Piece{type: :knight, color: :black},
        {2, 0} => %Chess.Piece{type: :bishop, color: :black},
        {3, 0} => %Chess.Piece{type: :queen, color: :black},
        {4, 0} => %Chess.Piece{type: :king, color: :black},
        {5, 0} => %Chess.Piece{type: :bishop, color: :black},
        {6, 0} => %Chess.Piece{type: :knight, color: :black},
        {7, 0} => %Chess.Piece{type: :rook, color: :black},
        {0, 1} => %Chess.Piece{type: :pawn, color: :black},
        {1, 1} => %Chess.Piece{type: :pawn, color: :black},
        {2, 1} => %Chess.Piece{type: :pawn, color: :black},
        {3, 1} => %Chess.Piece{type: :pawn, color: :black},
        {4, 1} => %Chess.Piece{type: :pawn, color: :black},
        {5, 1} => %Chess.Piece{type: :pawn, color: :black},
        {6, 1} => %Chess.Piece{type: :pawn, color: :black},
        {7, 1} => %Chess.Piece{type: :pawn, color: :black},

        {0, 2} => nil, {1, 2} => nil, {2, 2} => nil, {3, 2} => nil, {4, 2} => nil,
        {5, 2} => nil, {6, 2} => nil, {7, 2} => nil,

        {0, 3} => nil, {1, 3} => nil, {2, 3} => nil, {3, 3} => nil, {4, 3} => nil,
        {5, 3} => nil, {6, 3} => nil, {7, 3} => nil,

        {0, 4} => nil, {1, 4} => nil, {2, 4} => nil, {3, 4} => nil, {4, 4} => nil,
        {5, 4} => nil, {6, 4} => nil, {7, 4} => nil,

        {0, 5} => nil, {1, 5} => nil, {2, 5} => nil, {3, 5} => nil, {4, 5} => nil,
        {5, 5} => nil, {6, 5} => nil, {7, 5} => nil,

        {0, 6} => %Chess.Piece{type: :pawn, color: :white},
        {1, 6} => %Chess.Piece{type: :pawn, color: :white},
        {2, 6} => %Chess.Piece{type: :pawn, color: :white},
        {3, 6} => %Chess.Piece{type: :pawn, color: :white},
        {4, 6} => %Chess.Piece{type: :pawn, color: :white},
        {5, 6} => %Chess.Piece{type: :pawn, color: :white},
        {6, 6} => %Chess.Piece{type: :pawn, color: :white},
        {7, 6} => %Chess.Piece{type: :pawn, color: :white},
        {0, 7} => %Chess.Piece{type: :rook, color: :white},
        {1, 7} => %Chess.Piece{type: :knight, color: :white},
        {2, 7} => %Chess.Piece{type: :bishop, color: :white},
        {3, 7} => %Chess.Piece{type: :queen, color: :white},
        {4, 7} => %Chess.Piece{type: :king, color: :white},
        {5, 7} => %Chess.Piece{type: :bishop, color: :white},
        {6, 7} => %Chess.Piece{type: :knight, color: :white},
        {7, 7} => %Chess.Piece{type: :rook, color: :white},
      },
      capture_piles: %{black: [], white: []}  
    }
  end

 def testboard() do
    %Chess.Board{
      width: 8, height: 8, cells: %{
	{0, 0} => %Chess.Piece{type: :rook, color: :black},
	{1, 0} => nil,
	{2, 0} => %Chess.Piece{type: :bishop, color: :black},
	{3, 0} => nil,
	{4, 0} => %Chess.Piece{type: :rook, color: :black},
	{5, 0} => nil,
	{6, 0} => %Chess.Piece{type: :king, color: :color},
	{7, 0} => nil,

	{0, 1} => %Chess.Piece{type: :pawn, color: :black},
	{1, 1} => %Chess.Piece{type: :pawn, color: :black},
	{2, 1} => nil,
	{3, 1} => nil,
	{4, 1} => %Chess.Piece{type: :queen, color: :black},
	{5, 1} => %Chess.Piece{type: :pawn, color: :black},
	{6, 1} => %Chess.Piece{type: :pawn, color: :black},
	{7, 1} => %Chess.Piece{type: :pawn, color: :black},

	{0, 2} => nil,
	{1, 2} => nil,
	{2, 2} => %Chess.Piece{type: :knight, color: :black},
	{3, 2} => %Chess.Piece{type: :pawn, color: :black},
	{4, 2} => nil,
	{5, 2} => %Chess.Piece{type: :knight, color: :pawn},
	{6, 2} => nil,
	{7, 2} => nil,

	{0, 3} => nil,
	{1, 3} => nil,
	{2, 3} => %Chess.Piece{type: :pawn, color: :black},
	{3, 3} => nil,
	{4, 3} => nil,
	{5, 3} => nil,
	{6, 3} => nil,
	{7, 3} => nil,

	{0, 4} => nil,
	{1, 4} => nil,
	{2, 4} => %Chess.Piece{type: :pawn, color: :white},
	{3, 4} => %Chess.Piece{type: :pawn, color: :white},
	{4, 4} => %Chess.Piece{type: :pawn, color: :black},
	{5, 4} => nil,
	{6, 4} => nil,
	{7, 4} => nil,

	{0, 5} => %Chess.Piece{type: :pawn, color: :white},
	{1, 5} => nil,
	{2, 5} => %Chess.Piece{type: :queen, color: :white},
	{3, 5} => nil,
	{4, 5} => nil,
	{5, 5} => nil,
	{6, 5} => %Chess.Piece{type: :pawn, color: :white},
	{7, 5} => nil,

	{0, 6} => nil,
	{1, 6} => %Chess.Piece{type: :pawn, color: :white},
	{2, 6} => %Chess.Piece{type: :knight, color: :white},
	{3, 6} => nil,
	{4, 6} => %Chess.Piece{type: :pawn, color: :black},
	{5, 6} => %Chess.Piece{type: :pawn, color: :black},
	{6, 6} => %Chess.Piece{type: :bishop, color: :black},
	{7, 6} => %Chess.Piece{type: :pawn, color: :black},

	{0, 7} => %Chess.Piece{type: :rook, color: :white},
	{1, 7} => nil,
	{2, 7} => %Chess.Piece{type: :bishop, color: :white},
	{3, 7} => nil,
	{4, 7} => nil,
	{5, 7} => %Chess.Piece{type: :rook, color: :white},
	{6, 7} => %Chess.Piece{type: :king, color: :white},
	{7, 7} => nil
      },
      capture_piles: %{black: [], white: []}
    };
  end
end

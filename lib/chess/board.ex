defmodule Chess.Board do
  defstruct width: nil,
            height: nil,
            cells: %{},  # {coordinate} => %Chess.Piece{}
            capture_piles: %{black: [], white: []}  # Capture piles for both colors

  # Modify make_move to handle capturing a piece
  def make_move(board = %Chess.Board{cells: cells, capture_piles: capture_piles}, to, from) do
    if to == from do
      board
    else
      piece_to_capture = cells[to]

      # If there is an enemy piece, add it to the capture pile
      if piece_to_capture != nil and piece_to_capture.color != cells[from].color do
        updated_capture_piles = capture_piece(capture_piles, piece_to_capture)
        IO.inspect(updated_capture_piles, label: "Updated Capture Piles")
        board = %{board | capture_piles: updated_capture_piles}
      end

      # Move the piece and clear the old position
      %{board | cells: %{cells | to => cells[from], from => nil}}
    end
  end

  # Function to handle adding a captured piece to the capture pile
  defp capture_piece(capture_piles, piece) do
    # Add the captured piece to the appropriate capture pile
    case piece.color do
      :black -> %{capture_piles | black: [piece | capture_piles.black]}
      :white -> %{capture_piles | white: [piece | capture_piles.white]}
    end
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
        {4, 4} => nil,
        {5, 4} => nil,
        {6, 4} => nil,
        {7, 4} => nil
      },
      capture_piles: %{black: [], white: []}
    }
  end
end

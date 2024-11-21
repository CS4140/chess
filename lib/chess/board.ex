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
        _board = %{board | capture_piles: updated_capture_piles}
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
end

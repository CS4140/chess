defmodule Chess.Board do
  defstruct width: nil,
            height: nil,
            cells: %{},  # {coordinate} => %Chess.Piece{}
            capture_piles: %{black: [], white: []}  # Capture piles for both colors


  defp checkmate?(board, owner) do
    Enum.all?(Enum.filter(board.cells, fn {_pos, piece} -> piece != nil and owner == owner end), fn {pos, piece} ->
      Chess.Piece.Moves.get(board, piece, pos) == []
    end)
  end
  
  # Modify make_move to handle capturing a piece
  def make_move(board = %Chess.Board{cells: cells, capture_piles: _capture_piles}, to, from) do
    if to == from do
      board
    else
# Commented unused code
#      piece_to_capture = cells[to]
#
#      # If there is an enemy piece, add it to the capture pile
#      if piece_to_capture != nil and piece_to_capture.owner != cells[from].owner do
#        updated_capture_piles = capture_piece(capture_piles, piece_to_capture)
#        _board = %{board | capture_piles: updated_capture_piles}
#      end

      # Move the piece and clear the old position
      board = %{board | cells: %{cells | to => cells[from], from => nil}}

      # Check for checkmate after moving
      if checkmate?(board, cells[from].owner) do
        IO.puts("Checkmate detected!")
      end

      board
    end
  end

  # Return all of the pieces owned by owner on board
  def get_pieces(%Chess.Board{cells: cells}, owner) do
    Enum.filter(cells, fn {_, p} -> p != nil && p.owner == owner end)
  end

  # Update location to contain piece(s)
  def set_piece(board = %Chess.Board{cells: cells}, piece, pos) do
    %{board | cells: %{cells | pos => piece}}
  end

  def set_piece(board = %Chess.Board{cells: cells}, piece = %Chess.Piece{origin: pos}) do
    %{board | cells: %{cells | pos => piece}}
  end

  def set_pieces(board = %Chess.Board{}, []), do: board

  def set_pieces(board = %Chess.Board{cells: cells}, pieces) do
    set_pieces(
      %{board | cells: %{cells | List.first(pieces).origin => List.first(pieces)}},
      List.delete_at(pieces, 0)
    )
  end

  def get_king(%Chess.Board{cells: cells}, owner) do
    Enum.find(cells, fn {_, p} -> p && p.type == :king && p.owner == owner end)
  end

#  # Function to handle adding a captured piece to the capture pile
#  defp capture_piece(capture_piles, piece) do
#    # Add the captured piece to the appropriate capture pile
#    case piece.color do
#      :black -> %{capture_piles | black: [piece | capture_piles.black]}
#      :white -> %{capture_piles | white: [piece | capture_piles.white]}
#    end
#  end
end

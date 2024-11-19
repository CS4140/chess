# To re-enable all debug messages in this file, run the following command:
# sed 's/#IO/IO/g' -i piece.ex

defmodule Chess.Piece do
  defstruct color: nil,
            type: nil

  def glyphs() do
    %{:white =>
        %{:rook => "♖", :knight => "♘", :bishop => "♗", :queen => "♕", :king => "♔", :pawn => "♙"},
      :black =>
        %{:rook => "♜", :knight => "♞", :bishop => "♝", :queen => "♛", :king => "♚", :pawn => "♟"},
    }
  end
end

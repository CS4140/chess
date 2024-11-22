# This is the piece database schema _and_ struct used for games. Functions for
# manipulating pieces during a game are in Chess.Piece.Moves, and functions for
# storing/retrieving pieces in the database are in Chess.Piece.Inventory

defmodule Chess.Piece do
  use Ecto.Schema
#  import Ecto.Changeset
#  alias Chess.{Board, Repo, Accounts}

  schema "pieceinventory" do
    field :type, Ecto.Enum, values: [:rook, :knight, :bishop, :queen, :king, :pawn, :dragon, :wizard, :ninja, :phoenix]
    field :origin, {:array, :integer}
    belongs_to :owner, Chess.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def glyphs() do
    %{:white =>
        %{:rook => "♖", :knight => "♘", :bishop => "♗", :queen => "♕", :king => "♔", :pawn => "♙",
          :dragon => "🐉",    
          :wizard => "🧙‍♂️",    
          :ninja => "🥷",     
          :phoenix => "🦅"},
      :black =>
        %{:rook => "♜", :knight => "♞", :bishop => "♝", :queen => "♛", :king => "♚", :pawn => "♟",
          :dragon => "🐲",    # Changed to green dragon
          :wizard => "🧙🏿‍♂️",   # Changed to dark skin tone wizard
          :ninja => "👤",     # Changed to silhouette
          :phoenix => "🦢"}   # Changed to black swan
    }
  end
end

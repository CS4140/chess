defmodule Chess.Piece.Inventory do
  import Ecto.Query
  alias Chess.Repo
#  import Ecto.Changeset
#  alias Chess.{Board, Repo, Accounts}

  def get(%Chess.Accounts.User{id: id}) do
    Repo.all(from p in Chess.Piece, where: p.owner_id == ^id);
  end

  def get_board(board, %Chess.Accounts.User{id: id}) do
    pieces = Repo.all(from p in Chess.Piece, where: p.owner_id == ^id and not is_nil(p.origin));
    pieces
#loop over get(user) and add each piece to board, return baord
#    get() |> Enum.filter(fn piece -> piece.origin != nil end);
  end
end

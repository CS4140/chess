defmodule Chess.Piece.Inventory do
  import Ecto.Query
#  import Ecto.Changeset
#  alias Chess.{Board, Repo, Accounts}

  def get(%Chess.Accounts.User{id: id}) do
    Chess.Repo.all(from p in Chess.Piece, where: p.owner_id == ^id);
  end
end

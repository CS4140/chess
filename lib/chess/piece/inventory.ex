defmodule Chess.Piece.Inventory do
  import Ecto.Query
  alias Chess.Repo
#  import Ecto.Changeset

  def get(%Chess.Accounts.User{id: id}) do
    Repo.all(from p in Chess.Piece, where: p.owner_id == ^id);
  end

  def get_board(board, %Chess.Accounts.User{id: id}) do
    Chess.Board.set_pieces(board,
      Repo.all(from p in Chess.Piece, where: p.owner_id == ^id and not is_nil(p.origin))
    );
  end

  def get_floating(%Chess.Accounts.User{id: id}) do
      Repo.all(from p in Chess.Piece, where: p.owner_id == ^id and is_nil(p.origin))
  end
end

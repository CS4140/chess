defmodule Chess.Board.InitialStructure do
  use Ecto.Schema
  import Ecto.Changeset

  schema "initialstructures" do
    field :board, :binary
    field :user, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(initial_structure, attrs) do
    initial_structure
    |> cast(attrs, [:board])
    |> validate_required([:board])
  end

  def save(%Chess.Accounts.User{id: id}, %Chess.Board{cells: cells}) do
    s = %Chess.Board.InitialStructure{board: :erlang.term_to_binary(cells), user: id};
    Chess.Repo.insert(s);
  end

  def get(%Chess.Accounts.User{id: id}) do
    Chess.Repo.get_by(Chess.Board.InitialStructure, user: id).board
    |> :erlang.binary_to_term();
  end
end

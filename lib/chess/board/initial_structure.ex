defmodule Chess.Board.InitialStructure do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "initialstructures" do
    field :board, :binary
    field :user, :id, primary_key: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(initial_structure, attrs) do
    initial_structure
    |> cast(attrs, [:board])
    |> validate_required([:board])
  end
end

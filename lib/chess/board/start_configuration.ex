defmodule Chess.Board.StartConfiguration do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chess.{Board, Repo, Accounts}

  @primary_key false
  schema "startconfigurations" do
    field :board, :binary
    field :user, :id, primary_key: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  defp changeset(start_configuration, attrs) do
    start_configuration
    |> cast(attrs, [:board, :user])
    |> validate_required([:board, :user])
  end

  def get(%Accounts.User{id: id}) do
    if (result = Repo.get_by(__MODULE__, user: id)) do
      result
    else
      %__MODULE__{ user: id }
    end
  end

  def set(user = %Accounts.User{id: id}, %Board{cells: cells}) do
    get(user)
    |> changeset(%{board: :erlang.term_to_binary(cells), user: id})
    |> Repo.insert_or_update()
  end
end

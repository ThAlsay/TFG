defmodule Engine.Safe do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  schema "saves" do
    field(:safe, :map)

    timestamps()
  end

  def changeset(safe, params) do
    safe
    |> Ecto.Changeset.cast(params, [:id, :safe])
    |> Ecto.Changeset.validate_required([:id, :safe])
  end
end

defmodule Engine.User do
  use Ecto.Schema

  @primary_key {:username, :string, autogenerate: false}
  schema "players" do
    field(:password, :string)
    field(:character, :map)

    timestamps()
  end

  def changeset(user, params) do
    user
    |> Ecto.Changeset.cast(params, [:username, :password, :character])
    |> Ecto.Changeset.validate_required([:username, :password, :character])
  end
end

defmodule Engine.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:saves, primary_key: false) do
      add(:user_name, :string, primary_key: true)
      add(:safe, :jsonb, null: false)

      timestamps()
    end
  end
end

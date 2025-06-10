defmodule Engine.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add(:username, :string, primary_key: true)
      add(:password, :string, null: false)
      add(:character, :jsonb, null: false)

      timestamps()
    end
  end
end

defmodule ElixirPlayground.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:locations, [:name])
  end
end

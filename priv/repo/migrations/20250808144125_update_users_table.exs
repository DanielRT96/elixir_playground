defmodule ElixirPlayground.Repo.Migrations.UpdateUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :user_role, :string, default: "normal", null: false
    end
  end
end

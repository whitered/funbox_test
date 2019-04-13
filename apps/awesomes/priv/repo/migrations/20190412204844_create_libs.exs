defmodule Awesomes.Repo.Migrations.CreateLibs do
  use Ecto.Migration

  def change do
    create table("libs") do
      add :username, :string, null: false
      add :name, :string, null: false

      add :stars_count, :integer
      add :description, :string
      add :last_commit_at, :naive_datetime

      add :error, :string
    end
  end
end

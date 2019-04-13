defmodule Awesomes.Repo.Migrations.CreateSections do
  use Ecto.Migration

  def change do
    create table("categories") do
      add :title, :string, null: false
      add :description, :string, null: false
      add :list_id, references("libs"), null: false
    end

    create index("categories", [:list_id])
    create unique_index("categories", [:list_id, :title])

    alter table("libs") do
      remove :username
      remove :name
      add :repo, :string, null: false
      add :category_id, references("categories")
    end

    create index("libs", [:category_id])
    create unique_index("libs", [:repo])
  end
end

defmodule Awesomes.Repo.Migrations.AddFetchedAtToLibs do
  use Ecto.Migration

  def change do
    alter table("libs") do
      add :fetched_at, :naive_datetime
    end

    create index("libs", [:fetched_at])
  end
end

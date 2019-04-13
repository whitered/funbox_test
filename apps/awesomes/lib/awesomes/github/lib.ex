defmodule Awesomes.Github.Lib do
  use Ecto.Schema
  import Ecto.Changeset

  alias Awesomes.Repo

  schema "libs" do
    field :username, :string
    field :name, :string

    field :description, :string
    field :stars_count, :integer
    field :last_commit_at, :naive_datetime
    field :error, :string
  end

  def update_info(lib, params) do
    lib
    |> cast(params, [:description, :stars_count, :last_commit_at])
    |> Repo.update!()
  end

  def set_error(lib, error) do
    lib
    |> change(error: error)
    |> Repo.update!()
  end
end

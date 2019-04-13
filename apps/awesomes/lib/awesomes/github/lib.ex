defmodule Awesomes.Github.Lib do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Awesomes.Repo
  alias Awesomes.Github.Lib
  alias Awesomes.Github.Category

  schema "libs" do
    field :repo, :string
    field :description, :string
    field :stars_count, :integer
    field :last_commit_at, :naive_datetime
    field :error, :string

    # plain lib
    belongs_to :category, Category

    # awesome list
    has_many :categories, Category, foreign_key: :list_id
  end

  def awesome_list?(lib) do
    is_nil(lib.category_id)
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

  def insert_new(repo, category) do
    Repo.get_by(Lib, repo: repo)
    |> case do
      nil ->
        %Lib{repo: repo, category: category}
        |> Repo.insert!()

      lib ->
        lib
    end
  end

  def children_libs(list) do
    query =
      from l in Lib,
        join: c in Category,
        on: l.category_id == c.id,
        where: c.list_id == ^list.id

    Repo.all(query)
  end
end

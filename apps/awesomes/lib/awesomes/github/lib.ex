defmodule Awesomes.Github.Lib do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import Awesomes.Utils

  alias Awesomes.Repo
  alias Awesomes.Github.Lib
  alias Awesomes.Github.Category

  schema "libs" do
    field :repo, :string
    field :description, :string
    field :stars_count, :integer
    field :last_commit_at, :naive_datetime
    field :error, :string
    field :fetched_at, :naive_datetime

    # plain lib
    belongs_to :category, Category

    # awesome list
    has_many :categories, Category, foreign_key: :list_id
  end

  def get_list(repo) do
    Repo.one(
      from l in Lib,
        where: l.repo == ^repo and is_nil(l.category_id),
        limit: 1
    )
  end

  def get_first_list() do
    Repo.one(
      from l in Lib,
        where: is_nil(l.category_id),
        order_by: l.id,
        limit: 1
    )
  end

  def get_next_to_fetch() do
    Repo.one(
      from l in Lib,
        where: is_nil(l.error),
        order_by: [asc_nulls_first: :fetched_at],
        limit: 1
    )
  end

  def awesome_list?(lib) do
    is_nil(lib.category_id)
  end

  def update_info(lib, params) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    params = %{params | description: truncate(params.description)}

    lib
    |> cast(params, [:description, :stars_count, :last_commit_at])
    |> change(%{fetched_at: now})
    |> Repo.update!()
  end

  def set_error(lib, error) do
    lib
    |> change(error: truncate(error))
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

  def children_libs(list, params \\ []) do
    params
    |> Enum.reduce(children_query(list), &apply_filter/2)
    |> Repo.all()
  end

  defp apply_filter({:min_stars, min_stars}, query) do
    from l in query, where: l.stars_count >= ^min_stars
  end

  defp children_query(list) do
    from l in Lib,
      join: c in Category,
      on: l.category_id == c.id,
      where: c.list_id == ^list.id
  end

  def find_disappeared(actual_ids, list) do
    Repo.all(from l in children_query(list), where: l.id not in ^actual_ids)
  end

  def delete(lib) do
    Repo.delete!(lib)
  end
end

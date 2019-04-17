defmodule Awesomes.Github.Category do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  import Awesomes.Utils
  alias Awesomes.Repo
  alias Awesomes.Github.Category
  alias Awesomes.Github.Lib

  schema "categories" do
    field :title, :string
    field :description, :string

    belongs_to :list, Lib
    has_many :libs, Lib, on_delete: :delete_all
  end

  def get(ids) when is_list(ids) do
    Repo.all(from c in Category, where: c.id in ^ids)
  end

  def ensure_exists(list, title, description) do
    title = truncate(title)
    description = truncate(description)

    Category
    |> Repo.get_by(title: title, list_id: list.id)
    |> case do
      nil ->
        create(list, title, description)

      category ->
        category
        |> change(%{description: description})
        |> Repo.update!()
    end
  end

  defp create(list, title, description) do
    %Category{list: list, title: title, description: description}
    |> Repo.insert!()
  end

  def find_disappeared(actual_ids, list) do
    Repo.all(from c in Category, where: c.list_id == ^list.id and c.id not in ^actual_ids)
  end

  def delete(category) do
    Repo.delete!(category)
  end
end

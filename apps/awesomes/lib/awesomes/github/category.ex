defmodule Awesomes.Github.Category do
  use Ecto.Schema
  alias Awesomes.Repo
  alias Awesomes.Github.Category
  alias Awesomes.Github.Lib

  schema "categories" do
    field :title, :string
    field :description, :string

    belongs_to :list, Lib
    has_many :libs, Lib
  end

  def ensure_exists(list, title, description) do
    Category
    |> Repo.get_by(title: title, list_id: list.id)
    |> case do
      nil ->
        create(list, title, description)

      category ->
        category
    end
  end

  defp create(list, title, description) do
    %Category{list: list, title: title, description: description}
    |> Repo.insert!()
  end
end

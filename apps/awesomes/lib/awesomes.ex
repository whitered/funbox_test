defmodule Awesomes do
  alias Awesomes.Repo
  alias Awesomes.Github.Lib
  alias Awesomes.Github.Category

  def get_libs_with_categories(list, min_stars) do
    libs_by_cat =
      list
      |> Lib.children_libs(min_stars: min_stars)
      |> Enum.group_by(& &1.category_id)

    libs_by_cat
    |> Enum.map(fn {id, _} -> id end)
    |> Category.get()
    |> Enum.map(fn category -> {category, libs_by_cat[category.id]} end)
  end

  def create_list(repo) do
    Repo.insert(%Lib{repo: repo})
  end
end

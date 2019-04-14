defmodule Awesomes.Github.FetcherTest do
  use Awesomes.DataCase
  use Awesomes.Fixtures

  alias Awesomes.Repo
  alias Awesomes.Github.Lib
  alias Awesomes.Github.Category
  alias Awesomes.Github.Fetcher

  @repo "h4cc/awesome-elixir"
  @repo_missing "somebody/missing_repo"
  @categories_count 91
  @libs_count 1248

  setup :create_lib

  defp create_lib(context) do
    repo = context[:repo] || @repo

    lib =
      %Lib{repo: repo}
      |> Repo.insert!()

    [lib: lib]
  end

  defp reload(lib) do
    Repo.get(Lib, lib.id)
  end

  describe "fetching lib" do
    test "updates info", %{lib: lib} do
      assert :ok == Fetcher.run(lib)
      lib = reload(lib)
      assert 9122 == lib.stars_count
      assert lib.description =~ "amazingly awesome"
      assert ~N[2019-02-11 13:58:49] == lib.last_commit_at
    end
  end

  describe "fetching missing lib" do
    @describetag repo: @repo_missing

    test "updates repo error", %{lib: lib} do
      assert :ok == Fetcher.run(lib)
      lib = reload(lib)
      assert lib.error =~ "Not Found"
    end
  end

  describe "fetching awesome list" do
    defp count_entities(list) do
      children = Lib.children_libs(list)
      list = Repo.preload(list, :categories)
      assert @libs_count == length(children)
      assert @categories_count == length(list.categories)
    end

    test "creates child libs", %{lib: list} do
      Fetcher.run(list)
      count_entities(list)
    end

    test "deletes disappeared categories with included libs", %{lib: list} do
      category = Category.ensure_exists(list, "Disappearing category", "Bye-bye")
      lib = Lib.insert_new("disappearing/repo", category)
      Fetcher.run(list)
      assert nil == Repo.get(Category, category.id)
      assert nil == Repo.get(Lib, lib.id)
      count_entities(list)
    end

    test "deletes disappeared libs within survived category", %{lib: list} do
      category =
        Category.ensure_exists(
          list,
          "Actors",
          "Libraries and tools for working with actors and such."
        )

      lib = Lib.insert_new("disappearing/repo", category)
      Fetcher.run(list)
      refute nil == Repo.get(Category, category.id)
      assert nil == Repo.get(Lib, lib.id)
      count_entities(list)
    end

    test "updates category description", %{lib: list} do
      category = Category.ensure_exists(list, "Actors", "Previous description")
      Fetcher.run(list)
      category = Repo.get(Category, category.id)
      assert "Libraries and tools for working with actors and such." == category.description
    end
  end
end

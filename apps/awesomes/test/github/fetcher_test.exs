defmodule Awesomes.Github.FetcherTest do
  use Awesomes.DataCase
  use Awesomes.Fixtures

  alias Awesomes.Repo
  alias Awesomes.Github.Lib
  alias Awesomes.Github.Fetcher

  @repo "h4cc/awesome-elixir"
  @repo_missing "somebody/missing_repo"

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
    test "creates child libs", %{lib: list} do
      Fetcher.run(list)
      children = Lib.children_libs(list)
      list = Repo.preload(list, :categories)
      assert length(children) > 1200
      assert length(list.categories) > 20
    end
  end
end

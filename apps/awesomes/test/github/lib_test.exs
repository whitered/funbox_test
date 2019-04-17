defmodule Awesomes.Github.LibTest do
  use Awesomes.DataCase
  import Ecto.Changeset
  alias Awesomes.Github.Lib
  alias Awesomes.Github.Category

  defp ago(hours) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
    |> NaiveDateTime.add(-hours * 60 * 60, :second)
  end

  defp create_lib(repo, params \\ %{}) do
    %Lib{repo: repo}
    |> change(params)
    |> Repo.insert!()
  end

  describe "get_next_to_fetch" do
    test "returns the ancientest lib" do
      create_lib("repo/lib1", fetched_at: ago(1))
      create_lib("repo/lib2", fetched_at: ago(3))
      create_lib("repo/lib3", fetched_at: ago(2))

      next = Lib.get_next_to_fetch()
      assert "repo/lib2" == next.repo
    end

    test "returns not fetched before lib" do
      create_lib("repo/lib1", fetched_at: ago(1))
      create_lib("repo/lib2", fetched_at: nil)

      next = Lib.get_next_to_fetch()
      assert "repo/lib2" == next.repo
    end

    test "skips libs with error" do
      create_lib("repo/lib1", fetched_at: ago(3), error: "error")
      create_lib("repo/lib2", fetched_at: ago(1))

      next = Lib.get_next_to_fetch()
      assert "repo/lib2" == next.repo
    end

    test "return nil if no libs to fetch available" do
      assert nil == Lib.get_next_to_fetch()
    end
  end

  describe "update_info" do
    test "updates fetched_at" do
      lib = create_lib("repo/lib")
      params = %{description: "", stars_count: 1}
      lib = Lib.update_info(lib, params)

      age =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.diff(lib.fetched_at)

      assert age in 0..2
    end

    test "handles long description" do
      lib = create_lib("repo/lib")
      desc = String.duplicate("a", 300)
      assert Lib.update_info(lib, %{description: desc})
    end

    test "handles null description" do
      lib = create_lib("repo/lib")
      assert Lib.update_info(lib, %{description: nil})
    end
  end

  describe "set_error" do
    test "handles long error" do
      lib = create_lib("repo/lib")
      error = String.duplicate("a", 300)
      assert Lib.set_error(lib, error)
    end
  end

  describe "get_list" do
    test "returns list" do
      list = create_lib("repo/list")
      assert list == Lib.get_list("repo/list")
    end

    test "ignores plain libs" do
      list = create_lib("repo/list")

      category =
        %Category{title: "Category", description: "Description", list: list} |> Repo.insert!()

      create_lib("repo/lib", %{category: category})
      assert nil == Lib.get_list("repo/lib")
    end
  end
end

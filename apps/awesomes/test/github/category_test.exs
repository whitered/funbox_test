defmodule Awesomes.Github.CategoryTest do
  use Awesomes.DataCase
  alias Awesomes.Github.Category

  describe "get when params is list of ids" do
    test "returns list of categories" do
      list = create_lib("repo/list")
      c1 = create_category(list, %{title: "c1"})
      c2 = create_category(list, %{title: "c2"})
      _ = create_category(list, %{title: "c3"})
      ids = [c1.id, c2.id]
      cats = Category.get(ids)
      assert 2 == length(cats)
      assert Enum.any?(cats, &(&1.title == "c1"))
      assert Enum.any?(cats, &(&1.title == "c2"))
      refute Enum.any?(cats, &(&1.title == "c3"))
    end
  end
end

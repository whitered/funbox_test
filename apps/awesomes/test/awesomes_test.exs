defmodule Awesomes.Test do
  use Awesomes.DataCase

  @test_data %{
    "cat1" => %{
      "repo/lib11" => 11,
      "repo/lib12" => 22,
      "repo/lib13" => 33
    },
    "cat2" => %{
      "repo/lib2" => 33
    },
    "cat3" => %{
      "repo/lib3" => 3
    }
  }

  defp create_list(data) do
    list = create_lib("repo/list")

    Enum.each(data, fn {title, libs} ->
      cat = create_category(list, %{title: title})

      Enum.each(libs, fn {repo, stars} ->
        create_lib(repo, %{category_id: cat.id, stars_count: stars})
      end)
    end)

    list
  end

  describe "get_libs_with_categories" do
    test "returns libs and categories filtered by min_stars" do
      list = create_list(@test_data)
      result = Awesomes.get_libs_with_categories(list, 20)

      assert Enum.any?(result, fn {cat, _} -> cat.title == "cat1" end)
      assert Enum.any?(result, fn {cat, _} -> cat.title == "cat2" end)
      refute Enum.any?(result, fn {cat, _} -> cat.title == "cat3" end)
      refute Enum.any?(result, fn {_, libs} -> libs == [] end)

      {_, libs1} = Enum.find(result, fn {cat, _} -> cat.title == "cat1" end)
      assert 2 == length(libs1)
      assert Enum.any?(libs1, &(&1.repo == "repo/lib12"))
      assert Enum.any?(libs1, &(&1.repo == "repo/lib13"))
    end
  end
end

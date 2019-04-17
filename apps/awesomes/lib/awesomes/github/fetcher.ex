defmodule Awesomes.Github.Fetcher do
  require Logger
  alias Awesomes.Github.Client
  alias Awesomes.Github.Lib
  alias Awesomes.Github.Category
  alias Awesomes.Github.ReadmeParser

  def run(lib) do
    with :ok <- update_info(lib) do
      if Lib.awesome_list?(lib), do: update_readme(lib)
    end

    :ok
  end

  # TODO: fetch commit only if info's updated_at has changed
  # also: possible handle renamed repos (301 error)
  defp update_info(lib) do
    Logger.info("Fetching info: " <> lib.repo)

    with {:ok, response_info} <- Client.repo(lib),
         branch = response_info["default_branch"],
         {:ok, response_commit} <- Client.commit(lib, branch) do
      last_commit_at =
        response_commit
        |> get_in(["commit", "commit", "committer", "date"])
        |> NaiveDateTime.from_iso8601!()

      params = %{
        description: response_info["description"],
        stars_count: response_info["stargazers_count"],
        last_commit_at: last_commit_at
      }

      Lib.update_info(lib, params)
      :ok
    else
      {:error, :rate_limit_exceeded} ->
        {:error, :rate_limit_exceeded}

      {:error, reason} ->
        Lib.set_error(lib, reason)
        {:error, reason}
    end
  end

  defp update_readme(list) do
    Logger.info("Fetching readme: " <> list.repo)

    with {:ok, response} <- Client.readme(list) do
      actual_entities =
        response
        |> ReadmeParser.parse()
        |> Enum.map(&update_category(list, &1))

      actual_entities
      |> Enum.map(fn {category, _libs} -> category end)
      |> clean_missing_categories(list)

      actual_entities
      |> Enum.map(fn {_category, libs} -> libs end)
      |> List.flatten()
      |> clean_missing_libs(list)

      :ok
    end
  end

  defp update_category(list, %{title: title, description: description, libs: libs}) do
    category = Category.ensure_exists(list, title, description)
    libs = Enum.map(libs, &ensure_lib(&1, category))
    {category, libs}
  end

  defp ensure_lib(repo, category) do
    Lib.insert_new(repo, category)
  end

  defp clean_missing_categories(actual_categories, list) do
    actual_categories
    |> Enum.map(& &1.id)
    |> Category.find_disappeared(list)
    |> Enum.each(&Category.delete/1)
  end

  defp clean_missing_libs(actual_libs, list) do
    actual_libs
    |> Enum.map(& &1.id)
    |> Lib.find_disappeared(list)
    |> Enum.each(&Lib.delete/1)
  end
end

defmodule Awesomes.Github.Fetcher do
  alias Awesomes.Github.Client
  alias Awesomes.Github.Lib
  alias Awesomes.Github.Category
  alias Awesomes.Github.ReadmeParser

  def run(lib) do
    update_info(lib)
    if Lib.awesome_list?(lib), do: update_readme(lib)
    :ok
  end

  # TODO: fetch commit only if info's updated_at has changed
  defp update_info(lib) do
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
      {:error, reason} ->
        Lib.set_error(lib, reason)
        :ok
    end
  end

  defp update_readme(lib) do
    with {:ok, response} <- Client.readme(lib) do
      response
      |> ReadmeParser.parse()
      |> Enum.each(&update_category(lib, &1))

      :ok
    end
  end

  defp update_category(list, %{title: title, description: description, libs: libs}) do
    category = Category.ensure_exists(list, title, description)
    Enum.each(libs, &ensure_lib(&1, category))
  end

  defp ensure_lib(repo, category) do
    Lib.insert_new(repo, category)
  end
end

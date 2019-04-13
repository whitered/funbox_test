defmodule Awesomes.Github.Fetcher do
  alias Awesomes.Github.Client
  alias Awesomes.Github.Lib

  def run(lib) do
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
end

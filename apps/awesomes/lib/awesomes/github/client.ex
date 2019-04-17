defmodule Awesomes.Github.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.github.com/"
  plug Tesla.Middleware.Headers, "User-Agent": "awesomes"
  plug Tesla.Middleware.JSON
  plug Awesomes.Github.RateLimitsGuard

  def repo(lib) do
    lib
    |> repo_url()
    |> get()
    |> response()
  end

  def commit(lib, branch) do
    lib
    |> branch_url(branch)
    |> get()
    |> response()
  end

  def readme(lib) do
    lib
    |> readme_url()
    |> get()
    |> response()
  end

  defp response({:ok, %Tesla.Env{status: 200, body: body}}) do
    {:ok, body}
  end

  defp response({:ok, %Tesla.Env{status: status, body: %{"message" => message}, url: url}}) do
    {:error, "Error fetching #{url}: [#{status}] #{message}"}
  end

  defp response({:error, reason}) do
    {:error, to_string(reason)}
  end

  defp repo_url(%{repo: repo}) do
    "repos/" <> repo
  end

  defp branch_url(lib, branch) do
    Enum.join([repo_url(lib), "branches", branch], "/")
  end

  defp readme_url(lib) do
    repo_url(lib) <> "/readme"
  end
end

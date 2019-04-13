defmodule Awesomes.Fixtures do
  use ExUnit.CaseTemplate
  import Tesla.Mock

  @url_base "https://api.github.com/"
  @fixtures_path "test/fixtures/"

  setup do
    mock(fn
      %{method: :get, url: @url_base <> path = url} ->
        path
        |> to_filename()
        |> File.read()
        |> build_response(url)
    end)

    :ok
  end

  defp to_filename(path) do
    @fixtures_path <> String.replace(path, "/", "__") <> ".json"
  end

  defp build_response({:ok, content}, url) do
    content
    |> Jason.decode!()
    |> json(url: url)
  end

  defp build_response({:error, :enoent}, url) do
    "404"
    |> to_filename()
    |> File.read!()
    |> Jason.decode!()
    |> json(url: url, status: 404)
  end
end

defmodule AwesomesWeb.PageController do
  use AwesomesWeb, :controller
  alias Awesomes.Github.Lib

  def index(conn, params) do
    list = Lib.get_first_list()
    min_stars = params["min_stars"] || 0
    render_list(conn, list, min_stars)
  end

  def list(conn, %{"username" => username, "name" => name} = params) do
    repo = username <> "/" <> name
    list = Lib.get_list(repo)
    min_stars = params["min_stars"] || 0
    render_list(conn, list, min_stars)
  end

  defp render_list(conn, nil, _) do
    conn
    |> send_resp(404, "Not found")
    |> halt()
  end

  defp render_list(conn, list, min_stars) do
    cats = Awesomes.get_libs_with_categories(list, min_stars)
    render(conn, "index.html", list: list, cats: cats)
  end
end

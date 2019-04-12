defmodule AwesomesWeb.PageController do
  use AwesomesWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

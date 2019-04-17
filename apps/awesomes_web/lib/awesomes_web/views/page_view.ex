defmodule AwesomesWeb.PageView do
  use AwesomesWeb, :view

  @seconds_in_day 60 * 60 * 24

  def lib_url(lib) do
    "https://github.com/" <> lib.repo
  end

  def age(lib) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.diff(lib.last_commit_at)
    |> Integer.floor_div(@seconds_in_day)
  end
end

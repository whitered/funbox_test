defmodule Awesomes.Utils do
  def truncate(string) do
    cond do
      is_nil(string) ->
        nil

      String.length(string) > 255 ->
        {trunc, _} = String.split_at(string, 252)
        trunc <> "..."

      true ->
        string
    end
  end
end

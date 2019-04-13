defmodule Awesomes.Github.ReadmeParser do
  @acc %{categories: [], current: nil}
  @category %{title: nil, description: nil, libs: []}
  @lib_regex ~r{^\[([^]]*)\]\(https://github.com/([^)^/]*/[^)^/]*)\) - (.*)$}

  def parse(%{} = data) do
    data
    |> decode()
    |> String.split("\n")
    |> Enum.reduce(@acc, &process_line/2)
    |> build_result()
  end

  def decode(%{"encoding" => "base64", "content" => content}) do
    content
    |> String.split()
    |> Enum.map(&Base.decode64!/1)
    |> Enum.join()
  end

  defp process_line("## " <> title, %{categories: categories, current: current} = acc) do
    new_categories =
      case current do
        nil -> categories
        category -> [category | categories]
      end

    %{acc | categories: new_categories, current: %{@category | title: title}}
  end

  defp process_line(_, %{current: nil} = acc), do: acc

  defp process_line("* " <> str, acc) do
    case Regex.run(@lib_regex, str, capture: :all_but_first) do
      [_title, repo, _description] ->
        update_in(acc, [:current, :libs], fn libs -> [repo | libs] end)

      _ ->
        acc
    end
  end

  defp process_line("*" <> description, acc) do
    case String.split_at(description, -1) do
      {desc, "*"} ->
        put_in(acc, [:current, :description], desc)

      _ ->
        acc
    end
  end

  defp process_line(_, acc), do: acc

  defp build_result(%{categories: categories, current: current}) do
    [current | categories]
  end
end

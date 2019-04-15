defmodule Awesomes.Github.Updater do
  use Task
  require Logger

  alias Awesomes.Github.Fetcher
  alias Awesomes.Github.Lib

  @retry_interval 10_000
  @update_interval 24 * 60 * 60 * 1000

  def start_link(_) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    Lib.get_next_to_fetch()
    |> update()

    run()
  end

  defp update(nil) do
    :timer.sleep(@retry_interval)
  end

  defp update(lib) do
    lib.fetched_at
    |> get_delay()
    |> sleep()

    Fetcher.run(lib)
  end

  defp get_delay(nil), do: 0

  defp get_delay(fetched_at) do
    fetched_at
    |> NaiveDateTime.add(@update_interval, :millisecond)
    |> NaiveDateTime.diff(NaiveDateTime.utc_now(), :millisecond)
    |> min(0)
  end

  defp sleep(0), do: :ok

  defp sleep(delay) do
    Logger.info("Sleeping #{delay} ms before update")
    :timer.sleep(delay)
  end
end

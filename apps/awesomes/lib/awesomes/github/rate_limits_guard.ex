defmodule Awesomes.Github.RateLimitsGuard do
  use Agent
  require Logger

  @behaviour Tesla.Middleware

  @header_remaining :"X-RateLimit-Remaining"
  @header_reset :"X-RateLimit-Reset"

  def start_link(_) do
    Agent.start_link(fn -> {60, 0} end, name: __MODULE__)
  end

  def call(env, next, _options) do
    delay_till_rate_limits_reset()
    {:ok, env} = Tesla.run(env, next)
    update_rate_limits(env.headers)
    {:ok, env}
  end

  defp delay_till_rate_limits_reset() do
    {remaining, reset} = Agent.get(__MODULE__, & &1)

    case remaining do
      0 ->
        wait_until(reset)

      _ ->
        :ok
    end
  end

  defp wait_until(time) do
    delay =
      (time - :os.system_time(:second) + 1)
      |> max(0)
      |> Kernel.*(1000)

    Logger.info("Waiting for rate limits resetting (#{delay} ms)")
    :timer.sleep(delay)
  end

  defp update_rate_limits(headers) do
    remaining = Keyword.get(headers, @header_remaining)
    reset = Keyword.get(headers, @header_reset)

    Agent.update(__MODULE__, fn _ -> {remaining, reset} end)
  end
end

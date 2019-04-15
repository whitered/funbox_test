defmodule Awesomes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      [
        Awesomes.Repo,
        Awesomes.Github.RateLimitsGuard,
        if(Mix.env() != :test, do: Awesomes.Github.Updater)
      ]
      |> Enum.reject(&is_nil/1)

    Supervisor.start_link(children, strategy: :one_for_one, name: Awesomes.Supervisor)
  end
end

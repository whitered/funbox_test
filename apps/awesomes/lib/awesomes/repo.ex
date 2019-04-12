defmodule Awesomes.Repo do
  use Ecto.Repo,
    otp_app: :awesomes,
    adapter: Ecto.Adapters.Postgres
end

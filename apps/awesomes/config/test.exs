# Since configuration is shared in umbrella projects, this file
# should only configure the :awesomes application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :awesomes, Awesomes.Repo,
  username: "postgres",
  password: "postgres",
  database: "awesomes_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

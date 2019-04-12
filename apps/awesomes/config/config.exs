# Since configuration is shared in umbrella projects, this file
# should only configure the :awesomes application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :awesomes,
  ecto_repos: [Awesomes.Repo]

import_config "#{Mix.env()}.exs"

# Since configuration is shared in umbrella projects, this file
# should only configure the :awesomes_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :awesomes_web,
  ecto_repos: [Awesomes.Repo],
  generators: [context_app: :awesomes]

# Configures the endpoint
config :awesomes_web, AwesomesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Xaxs00vrhd4ZHRgmNKsTXdNb0xIa262dELKP9TA8CA5UIGSfxguvXLAY0pK/7X+d",
  render_errors: [view: AwesomesWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AwesomesWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

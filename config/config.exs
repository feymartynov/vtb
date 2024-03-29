# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :vtb,
  ecto_repos: [Vtb.Repo],
  from_email: {"ВТБ Голосование", "noreply@vtb.com"}

# Configures the endpoint
config :vtb, VtbWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "f14mHN8FFQggocLrNSKpDERnFUiuNebiRjqsI9rit+hiv2gZXqluEfJ0yIINBOBV",
  render_errors: [view: VtbWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Vtb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :arc, storage: Arc.Storage.Local

config :vtb, Vtb.Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "Vtb",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: %{"k" => "Q5b9Kw9dTxRdZp-RQOrj3A", "kty" => "oct"},
  serializer: Vtb.Guardian

config :vtb, Vtb.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.gmail.com",
  port: 587,
  username: {:system, "SMTP_USERNAME"},
  password: {:system, "SMTP_PASSWORD"},
  tls: :if_available,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  ssl: false,
  retries: 1

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

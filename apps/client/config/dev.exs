use Mix.Config

config :client, port: String.to_integer(System.get_env("PORT")) || 5000

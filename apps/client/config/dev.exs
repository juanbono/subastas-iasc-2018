use Mix.Config

port = System.get_env("PORT") || "5000"

config :client, port: String.to_integer(port)

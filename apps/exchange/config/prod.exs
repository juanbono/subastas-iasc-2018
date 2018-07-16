use Mix.Config

# Run release:
# env MIX_ENV=prod mix release --env=prod
# REPLACE_OS_VARS=true PORT=4000 ./_build/prod/rel/exchange/bin/exchange foreground

# NOTE: Use $PORT environment variable if specified, otherwise fallback to port 80
# port =
#   case System.get_env("PORT") do
#     port when is_binary(port) ->
#       String.to_integer(port)

#     # default port
#     nil ->
#       80
#   end
config :exchange, port: "${PORT}"

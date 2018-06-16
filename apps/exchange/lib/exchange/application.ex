defmodule Exchange.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: Exchange.Router,
        options: [port: 4001]
      )
    ]

    opts = [strategy: :one_for_one, name: Exchange.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

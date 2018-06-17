defmodule Client.Application do
  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:client, :port)

    children = [
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: Client.Router,
        options: [port: port]
      )
    ]

    opts = [strategy: :one_for_one, name: Client.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Exchange.Application do
  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:exchange, :port)

    plug_spec =
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: Exchange.Router,
        options: [port: port]
      )

    buyers_supervisor_spec =
      {DynamicSupervisor, name: Exchange.Buyers.Supervisor, strategy: :one_for_one}

    bids_supervisor_spec =
      {DynamicSupervisor, name: Exchange.Bids.Supervisor, strategy: :one_for_one}

    children = [
      plug_spec,
      Supervisor.child_spec(buyers_supervisor_spec, id: :buyers_supervisor),
      Supervisor.child_spec(bids_supervisor_spec, id: :bids_supervisor)
    ]

    opts = [strategy: :one_for_one, name: Exchange.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

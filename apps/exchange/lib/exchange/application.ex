defmodule Exchange.Application do
  @moduledoc """
  Modulo Aplicacion de la Exchange. Explicar
  """
  use Application
  alias Plug.Adapters.Cowboy2
  import Supervisor.Spec

  def start(_type, _args) do
    port_from_env = System.get_env("PORT") || "4000"
    port = String.to_integer(port_from_env)

    topologies = Application.get_env(:libcluster, :topologies)

    cluster_sup_spec = {Cluster.Supervisor, [topologies, [name: Exchange.ClusterSupervisor]]}

    plug_spec =
      Cowboy2.child_spec(
        scheme: :http,
        plug: Exchange.Router,
        options: [port: port]
      )

    children = [
      cluster_sup_spec,
      plug_spec,
      supervisor(Exchange.Bids.Supervisor, []),
      supervisor(Exchange.Buyers.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Exchange.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Exchange.Buyers.Supervisor do
  use DynamicSupervisor

  alias Exchange.{Buyers, Buyers.Buyer}

  def init(_args) do
    DynamicSupervisor.init([])
  end

  @doc """
  Registra un comprador en el sistema. En caso de recibir un error, lo devuelve.
  """
  def register({:error, _} = error), do: error

  def register(%Buyer{} = buyer) do
    DynamicSupervisor.start_child(Buyers.Supervisor, {Buyers.Worker, buyer})
  end

  @doc """
  Devuelve una lista con los PIDs de los compradores en el sistema.
  """
  def current_buyers() do
    DynamicSupervisor.which_children(Buyers.Supervisor)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  @doc """
  Cantidad de compradores en el sistema.
  """
  def number_of_buyers() do
    DynamicSupervisor.count_children(Buyers.Supervisor).workers
  end

  def names_to_pids(buyer_names) do
    current_buyers()
    |> Enum.filter(fn pid -> Buyers.Worker.in?(pid, buyer_names) end)
  end
end

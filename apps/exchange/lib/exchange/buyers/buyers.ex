defmodule Exchange.Buyers do
  alias Exchange.Buyers

  @doc """
  Registra un comprador en el sistema.
  """
  def register(buyer) do
    DynamicSupervisor.start_child(Buyers.Supervisor, {Buyers.Worker, buyer})
    children_count = DynamicSupervisor.count_children(Buyers.Supervisor).workers
    {:ok, children_count}
  end
end

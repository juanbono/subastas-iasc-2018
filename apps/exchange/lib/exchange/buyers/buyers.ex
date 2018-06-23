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

  def get_current_buyers() do
    DynamicSupervisor.which_children(Buyers.Supervisor)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end
end

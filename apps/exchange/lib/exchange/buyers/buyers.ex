defmodule Exchange.Buyers do
  alias Exchange.Buyers

  @doc """
  Registra un comprador en el sistema.
  """
  def register(buyer) do
    DynamicSupervisor.start_child(Buyers.Supervisor, {Buyers.Worker, buyer})
    {:ok, number_of_buyers()}
  end

  def current_buyers() do
    DynamicSupervisor.which_children(Buyers.Supervisor)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  def number_of_buyers() do
    DynamicSupervisor.count_children(Buyers.Supervisor).workers
  end
end

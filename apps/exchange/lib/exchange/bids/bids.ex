defmodule Exchange.Bids do
  alias Exchange.Bids

  @doc """
  Registra una apuesta en el sistema.
  """
  def register(bid) do
    DynamicSupervisor.start_child(Bids.Supervisor, {Bids.Worker, bid})
    {:ok, number_of_bids()}
  end

  def current_bids() do
    DynamicSupervisor.which_children(Bids.Supervisor)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  def number_of_bids() do
    DynamicSupervisor.count_children(Bids.Supervisor).workers
  end

  def exists?(bid_id) do
    # check if the given bid exists
  end
end

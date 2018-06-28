defmodule Exchange.Buyers do
  use Exchange.Validator, :buyers
  alias Exchange.Buyers

  def process(payload) do
    case valid?(payload) do
      {:ok, buyer} -> register(buyer)
      {:error, _} -> {:error, :invalid_json}
    end
  end

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

  def notify_buyers(bid) do
    current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify(pid, bid) end)
  end

  def number_of_buyers() do
    DynamicSupervisor.count_children(Buyers.Supervisor).workers
  end
end

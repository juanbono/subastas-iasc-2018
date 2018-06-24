defmodule Exchange do
  alias Exchange.Buyers

  @doc """
  Notifica a cada uno de los compradores actuales una `apuesta` dada.
  """
  def create_bid(bid) do
    Buyers.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify(pid, bid) end)
  end

  def number_of_buyers() do
    Exchange.Buyers.number_of_buyers()
  end

  def number_of_bids() do
    Exchange.Bids.number_of_bids()
  end

  def update_bid(bid) do
  end
end

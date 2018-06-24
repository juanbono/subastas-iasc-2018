defmodule Exchange do
  alias Exchange.Buyers
  alias Exchange.Bids

  @doc """
  Notifica a cada uno de los compradores actuales una `apuesta` dada.
  """
  def create_bid(bid) do
    Buyers.notify_buyers(bid)
  end

  def number_of_buyers() do
    Buyers.number_of_buyers()
  end

  def number_of_bids() do
    Bids.number_of_bids()
  end

  def update_bid(bid) do
  end
end

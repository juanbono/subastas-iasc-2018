defmodule Exchange do
  alias Exchange.Buyers

  @doc """
  Notifica a cada uno de los compradores actuales una `apuesta` dada.
  """
  def send_bid_to_buyers(bid) do
    Buyers.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify(pid, bid) end)
  end
end

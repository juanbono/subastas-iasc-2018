defmodule Exchange.Bids do
  alias Exchange.Bids
  alias Exchange.Bids.{Bid, Offer}

  def process(:bid, params) do
    Bid.make(params)
    |> register()
  end

  def process(:offer, params) do
    Offer.make(params)
    |> apply()
  end

  @doc """
  Aplica una `oferta`.
  """
  def apply({:error, _} = error), do: error

  def apply(offer) do
    # procesar el cambio
  end

  @doc """
  Registra una apuesta en el sistema.
  """
  def register({:error, _} = error), do: error

  def register(%Bid{} = bid) do
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
    bids =
      Bids.current_bids()
      |> Enum.map(fn bid_pid -> Bids.Worker.bid_id(bid_pid) end)

    if Enum.member?(bids, bid_id) do
      :invalid_bid_id
    else
      :ok
    end
  end
end

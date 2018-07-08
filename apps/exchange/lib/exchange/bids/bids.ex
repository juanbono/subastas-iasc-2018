defmodule Exchange.Bids do
  alias Exchange.{Bids, Bids.Bid, Bids.Offer}

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

  def apply(%Offer{} = offer) do
    Bids.Worker.update(offer)
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

  def get_bid(bid_id) do
    current_bids()
    |> Enum.find({:error, :bid_not_found}, fn pid -> Bids.Worker.bid_id(pid) == bid_id end)
    |> (fn pid -> Bids.Worker.get_state(pid) end).()
  end

  def get_bid_pid(bid_id) do
    current_bids()
    |> Enum.find({:error, :bid_not_found}, fn pid -> Bids.Worker.bid_id(pid) == bid_id end)
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

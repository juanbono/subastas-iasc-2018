defmodule Exchange.Bids do
  use Exchange.Validator, :bids
  alias Exchange.Bids
  alias Exchange.Bids.Bid

  def process(:bid, params) do
    Bid.make(params)
    |> register()
  end

  def process(:offer, payload) do
    case valid?(payload["id"], payload) do
      {:ok, offer} -> Exchange.create_bid(offer)
      {:error, _} -> {:error, :invalid_json}
    end
  end

  @doc """
  Registra una apuesta en el sistema.
  """
  def register({:error, _} = error), do: error

  def register(bid) do
    DynamicSupervisor.start_child(Bids.Supervisor, {Bids.Worker, bid})
    {:ok, number_of_bids()}
  end

  def check_update(offer) do
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

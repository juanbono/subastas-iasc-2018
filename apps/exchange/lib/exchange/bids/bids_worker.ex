defmodule Exchange.Bids.Worker do
  use GenServer
  alias Exchange.{Bids, Bids.Bid, Bids.Offer}

  #######################
  ## Funciones Cliente ##
  #######################

  def bid_id(bid_pid), do: GenServer.call(bid_pid, {:get_bid_id})

  def get_state({:error, _} = error), do: error
  def get_state(bid_pid), do: GenServer.call(bid_pid, {:get_state})

  def update(%Offer{} = offer) do
    bid_pid = Bids.get_bid_pid(offer.bid_id)
    GenServer.call(bid_pid, {:update, offer})
  end

  ########################
  ## Funciones Servidor ##
  ########################

  @doc """
  Inicializa el Worker con los datos de la `apuesta` como estado.
  """
  def init(%Bid{} = bid) do
    {:ok, Map.put(bid, :bid_id, UUID.uuid1())}
  end

  def start_link(bid_data) do
    GenServer.start_link(__MODULE__, bid_data, debug: [:statistics, :trace])
  end

  def handle_call({:get_bid_id}, _from, %{bid_id: bid_id} = state) do
    {:reply, bid_id, state}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call({:update, offer}, _from, state) do
    new_state = %Bid{
      bid_id: state.bid_id,
      price: offer.price,
      duration: state.duration,
      json: state.json,
      tags: state.json
    }

    {:reply, new_state, new_state}
  end
end

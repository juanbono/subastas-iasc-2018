defmodule Exchange.Bids.Worker do
  use GenServer
  alias Exchange.Bids.Bid

  #######################
  ## Funciones Cliente ##
  #######################

  def bid_id(bid_pid), do: GenServer.call(bid_pid, {:get_bid_id})

  def get_state({:error, _} = error), do: error
  def get_state(bid_pid), do: GenServer.call(bid_pid, {:get_state})

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
end

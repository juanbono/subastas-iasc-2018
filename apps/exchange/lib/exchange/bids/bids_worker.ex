defmodule Exchange.Bids.Worker do
  @moduledoc """
  Cada `Exchange.Bids.Worker` mantiene el estado de una `apuesta` especifica.
  Debe destruirse luego de pasado el tiempo especificado en la `apuesta`.
  """
  use GenServer
  alias Exchange.{Bids, Bids.Bid, Bids.Offer, Buyers}

  #######################
  ## Funciones Cliente ##
  #######################

  @doc """
  Obtiene el `id` de la `apuesta`.
  """
  def bid_id(bid_pid), do: GenServer.call(bid_pid, {:get_bid_id})

  @doc """
  Obtiene los datos de la `apuesta`.
  """
  def get_state({:error, _} = error), do: error
  def get_state(bid_pid), do: GenServer.call(bid_pid, {:get_state})

  @doc """
  Actualiza los datos de la `apuesta` con la `oferta` dada.
  """
  def update(%Offer{} = offer) do
    bid_pid = Bids.get_bid_pid(offer.bid_id)
    GenServer.call(bid_pid, {:update, offer})
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :transient
    }
  end

  ########################
  ## Funciones Servidor ##
  ########################

  @doc """
  Inicializa el Worker con los datos de la `apuesta` como estado.
  """
  def init(%Bid{} = bid) do
    new_bid =
      bid
      |> Map.put(:bid_id, UUID.uuid1())
      |> Map.put(:interested_buyers, MapSet.new())

    schedule_timeout(bid)

    {:ok, new_bid}
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
      tags: state.tags,
      interested_buyers: MapSet.put(state.interested_buyers, offer.buyer),
      winner: offer.buyer
    }

    {:reply, new_state, new_state}
  end

  def handle_info(:timeout, state) do
    Buyers.notify_buyers(:termination, state)
    Process.exit(self(), :normal)
  end

  def schedule_timeout(bid) do
    Process.send_after(self(), :timeout, bid.duration)
  end
end

defmodule Exchange.Bids.Worker do
  @moduledoc """
  Cada `Exchange.Bids.Worker` mantiene el estado de una `apuesta` especifica.
  Debe destruirse luego de pasado el tiempo dado al momento de creacion de la `apuesta`.
  """

  use GenServer, restart: :transient

  alias :mnesia, as: Mnesia
  alias Exchange.{Bids, Bids.Bid, Bids.Offer, Bids.Interfaces.Buyers}

  require Logger

  #######################
  ## Funciones Cliente ##
  #######################

  @doc """
  Inicializa el Worker con los datos de la `apuesta` como estado.
  """
  def init([%Bid{} = bid]) do
    new_bid =
      bid
      |> schedule_timeout()

    {:ok, new_bid}
  end

  def start_link(bid), do: GenServer.start_link(__MODULE__, [bid])

  @doc """
  Obtiene el `id` de la `apuesta`.
  """
  def bid_id(pid), do: GenServer.call(pid, {:get_bid_id})

  @doc """
  Obtiene los datos de la `apuesta`.
  """
  def get_state({:error, _} = error), do: error
  def get_state(pid), do: GenServer.call(pid, {:get_state})

  def notify_new_buyer(pid, buyer_pid) do
    GenServer.cast(pid, {:notify_new_buyer, buyer_pid})
  end

  @doc """
  Actualiza los datos de la `apuesta` con la `oferta` dada.
  """
  def update(%Offer{} = offer) do
    offer.bid_id
    |> Bids.get_bid_pid()
    |> GenServer.call({:update, offer})
  end

  @doc """
  Cancela una `apuesta`.
  """
  def cancel(id) do
    id
    |> Bids.get_bid_pid()
    |> GenServer.cast({:cancel})
  end

  ########################
  ## Funciones Servidor ##
  ########################

  def handle_call({:get_bid_id}, _from, %{bid_id: id} = state), do: {:reply, id, state}

  def handle_call({:get_state}, _from, state), do: {:reply, {:ok, state}, state}

  def handle_call({:update, offer}, _from, state) do
    new_state = %Bid{
      bid_id: state.bid_id,
      price: offer.price,
      close_at: state.close_at,
      json: state.json,
      tags: state.tags,
      winner: offer.buyer,
      state: "update"
    }

    {:reply, new_state, new_state}
  end

  def handle_cast({:notify_new_buyer, buyer_pid}, state) do
    Exchange.Buyers.Worker.notify_update(buyer_pid, state)

    {:noreply, state}
  end

  def handle_cast({:cancel}, state) do
    %{state | state: "cancelled"}
      |> persist
      |> notify_buyers(:finalized)

    Process.exit(self(), :normal)
  end

  def handle_info(:finalize, state) do
    %{state | state: "finalized"}
      |> persist
      |> notify_buyers(:finalized)

    Process.exit(self(), :normal)
  end

  def handle_info(msg, _state) do
    Logger.info("Received unknown message: #{inspect(msg)}")
  end

  ##########################
  ## Funciones Auxiliares ##
  ##########################

  def persist(bid) do
    Mnesia.transaction(fn ->
      Mnesia.write({
        :bid_table,
        bid.bid_id,
        bid.price,
        bid.close_at,
        bid.json,
        bid.tags,
        bid.winner,
        bid.state
      })
    end)

    bid
  end

  def notify_buyers(bid, status) do
    Buyers.Local.notify_buyers(status, bid)

    bid
  end

  def schedule_timeout(bid) do
    duration = DateTime.diff(bid.close_at, DateTime.utc_now()) * 1000
    Process.send_after(self(), :finalize, duration)
    bid
  end
end

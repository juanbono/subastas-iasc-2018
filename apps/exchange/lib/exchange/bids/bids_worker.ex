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

  def handle_cast({:cancel}, state) do
    new_bid = %{state | state: "cancelled"}

    Mnesia.transaction(fn ->
      Mnesia.write({
        :bid_table,
        new_bid.bid_id,
        new_bid.price,
        new_bid.close_at,
        new_bid.json,
        new_bid.tags,
        new_bid.winner,
        new_bid.state
      })
    end)

    Buyers.Local.notify_buyers(:cancelled, new_bid)

    Process.exit(self(), :normal)
  end

  def handle_info(:finalize, state) do
    new_bid = %{state | state: "finalized"}

    Mnesia.transaction(fn ->
      Mnesia.write({
        :bid_table,
        new_bid.bid_id,
        new_bid.price,
        new_bid.close_at,
        new_bid.json,
        new_bid.tags,
        new_bid.winner,
        new_bid.state
      })
    end)

    Buyers.Local.notify_buyers(:finalized, new_bid)

    Process.exit(self(), :normal)
  end

  def handle_info(msg, _state) do
    Logger.info("Received unknown message: #{inspect(msg)}")
  end

  def schedule_timeout(bid) do
    duration = DateTime.diff(bid.close_at, DateTime.utc_now()) * 1000
    Process.send_after(self(), :finalize, duration)
    bid
  end
end

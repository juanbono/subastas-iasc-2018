defmodule Exchange.Bids.Worker do
  @moduledoc """
  Cada `Exchange.Bids.Worker` mantiene el estado de una `apuesta` especifica.
  Debe destruirse luego de pasado el tiempo dado al momento de creacion de la `apuesta`.
  """

  use GenServer, restart: :transient

  alias Exchange.{Utils, Bids, Bids.Bid, Bids.Offer}
  alias Mnesiam.Support.BidStore
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
    new_state = %Bid{state | price: offer.price, winner: offer.buyer, state: "update"}

    {:reply, new_state, new_state}
  end

  # called when a handoff has been initiated due to changes
  # in cluster topology, valid response values are:
  #
  #   - `:restart`, to simply restart the process on the new node
  #   - `{:resume, state}`, to hand off some state to the new process
  #   - `:ignore`, to leave the process running on its current node
  #
  def handle_call({:swarm, :begin_handoff}, _from, some_state) do
    Logger.info("Begin Handoff: #{inspect(some_state)}")
    {:reply, {:resume, some_state}, some_state}
  end

  # called after the process has been restarted on its new node,
  # and the old process' state is being handed off. This is only
  # sent if the return to `begin_handoff` was `{:resume, state}`.
  # **NOTE**: This is called *after* the process is successfully started,
  # so make sure to design your processes around this caveat if you
  # wish to hand off state like this.
  def handle_cast({:swarm, :end_handoff, some_state}, sarasa) do
    Logger.info("Sarasa: #{inspect(sarasa)}")
    Logger.info("End Handoff: #{inspect(some_state)}")
    {:noreply, some_state}
  end

  # called when a network split is healed and the local process
  # should continue running, but a duplicate process on the other
  # side of the split is handing off its state to us. You can choose
  # to ignore the handoff state, or apply your own conflict resolution
  # strategy
  def handle_cast({:swarm, :resolve_conflict, _delay}, state) do
    {:noreply, state}
  end

  def handle_cast({:notify_new_buyer, buyer_pid}, state) do
    Exchange.Buyers.Worker.notify_new(buyer_pid, state)

    {:noreply, state}
  end

  def handle_cast({:cancel}, state) do
    %{state | state: "cancelled"}
    |> BidStore.store()
    |> notify_buyers(:finalized)

    Process.exit(self(), :normal)
  end

  def handle_info(:finalize, %Bid{timeout: timeout} = state) when timeout - 1 == 0 do
    %{state | state: "finalized"}
    |> BidStore.store()
    |> notify_buyers(:finalized)

    Process.exit(self(), :normal)
  end

  def handle_info(:finalize, %Bid{timeout: timeout} = state) do
    new_close_at = Utils.Time.add_sec(state.close_at, 5)
    new_bid = %{state | close_at: new_close_at, timeout: timeout - 1}

    {:noreply, new_bid}
  end

  # mensaje recibido cuando el proceso esta a punto de ser movido a otro
  # nodo del cluster.
  def handle_info({:swarm, :die}, state) do
    Logger.info("Swarm die msg received!")
    Logger.info("State before death: #{inspect(state)}")
    {:stop, :shutdown, state}
  end

  def handle_info(msg, _state) do
    Logger.info("Mensaje desconocido: #{inspect(msg)}")
  end

  ##########################
  ## Funciones Auxiliares ##
  ##########################

  def notify_buyers(bid, status) do
    Exchange.Bids.Interfaces.Buyers.Local.notify_buyers(status, bid)

    bid
  end

  ##########################
  ## Funciones Auxiliares ##
  ##########################

  defp schedule_timeout(bid) do
    duration = DateTime.diff(bid.close_at, DateTime.utc_now()) * 1000
    new_bid = %Bid{bid | timeout: bid.timeout + 1}
    Process.send_after(self(), :finalize, duration)
    new_bid
  end
end

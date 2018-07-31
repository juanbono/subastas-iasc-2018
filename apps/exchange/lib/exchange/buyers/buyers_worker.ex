defmodule Exchange.Buyers.Worker do
  @moduledoc """
  Worker que representa un comprador. Explicar
  """
  use GenServer
  require Logger
  alias Exchange.Buyers.Buyer

  #######################
  ## Funciones Cliente ##
  #######################

  @doc """
  Inicializa el Worker con los datos del `comprador` como estado.
  """
  def init([%Buyer{} = buyer]), do: {:ok, buyer}

  def start_link(buyer), do: GenServer.start_link(__MODULE__, [buyer])

  @doc """
  Devuelve el nombre del `comprador` con el `pid` dado.
  """
  def name(pid), do: GenServer.call(pid, {:get_name})

  @doc """
  Notifica al comprador con el `pid` dado sobre la creacion de
  una `apuesta`.
  """
  def notify_new(pid, bid), do: GenServer.cast(pid, {:bid_new, bid})

  @doc """
  Notifica al comprador con el `pid` dado sobre
  la actualización de una `apuesta`.
  """
  def notify_update(pid, bid), do: GenServer.cast(pid, {:bid_updated, bid})

  @doc """
  Notifica al comprador con el `pid` dado sobre
  la cancelación de una `apuesta`.
  """
  def notify_cancelled(pid, bid), do: GenServer.cast(pid, {:bid_cancelled, bid})

  @doc """
  Notifica al comprador con el `pid` dado sobre
  la finalización de una `apuesta`.
  """
  def notify_finalized(pid, bid), do: GenServer.cast(pid, {:bid_finalized, bid})

  @doc """
  Verifica si el nombre del `comprador` se encuentra dentro
  de la lista de compradores dada.
  """
  def in?(pid, buyers_list), do: GenServer.call(pid, {:name_is_in, buyers_list})

  ########################
  ## Funciones Servidor ##
  ########################

  def handle_cast({:bid_new, bid}, %Buyer{ip: ip, tags: tags} = state) do
    if has_tags_in_common?(bid.tags, tags) do
      body = make_body(bid)

      spawn(fn -> send_request(body, "#{ip}/bids/open") end)
    end

    {:noreply, state}
  end

  def handle_cast({:bid_updated, bid}, %Buyer{ip: ip} = state) do
    bid
    |> make_body()
    |> send_request("#{ip}/bids/new_offer")

    {:noreply, state}
  end

  def handle_cast({:bid_cancelled, bid}, %Buyer{ip: ip} = state) do
    bid
    |> make_body()
    |> send_request("#{ip}/bids/close")

    {:noreply, state}
  end

  def handle_cast({:bid_finalized, bid}, %Buyer{ip: ip} = state) do
    bid
    |> make_body()
    |> send_request("#{ip}/bids/close")

    {:noreply, state}
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

  def handle_call({:get_name}, _from, %Buyer{name: name} = state),
    do: {:reply, name, state}

  def handle_call({:name_is_in, list}, _from, %Buyer{name: name} = state),
    do: {:reply, Enum.member?(list, name), state}

  def handle_info(:timeout, {name, delay}) do
    IO.puts("#{inspect(name)} says hi!")
    Process.send_after(self(), :timeout, delay)
    {:noreply, {name, delay}}
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

  defp make_body(bid), do: bid |> encode_bid() |> Poison.encode!()

  defp send_request(body, url) do
    case HTTPoison.post(url, body, [{"content-type", "application/json"}]) do
      {:ok, res} -> Logger.info(inspect(res))
      {:error, reason} -> Logger.warn(inspect(reason))
    end
  end

  defp has_tags_in_common?(bid_tags, buyer_tags) do
    bid_tags
    |> Enum.any?(fn tag -> Enum.member?(buyer_tags, tag) end)
  end

  defp encode_bid(bid) do
    %{
      id: bid.bid_id,
      json: bid.json,
      price: bid.price,
      tags: bid.tags,
      winner: bid.winner,
      close_at: bid.close_at,
      state: bid.state
    }
  end
end

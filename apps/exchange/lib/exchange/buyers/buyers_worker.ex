defmodule Exchange.Buyers.Worker do
  use GenServer
  alias Exchange.{Buyers.Buyer, Bids.Bid}

  #######################
  ## Funciones Cliente ##
  #######################

  @doc """
  Devuelve el nombre del `comprador` con el `pid` dado.
  """
  def name(buyer_pid) do
    GenServer.call(buyer_pid, {:get_name})
  end

  @doc """
  Notifica al comprador con el `pid` dado sobre la creacion de
  una `apuesta`.
  """
  def notify_new(pid, %Bid{} = bid) do
    GenServer.cast(pid, {:bid_created, bid})
  end

  @doc """
  Notifica al comprador con el `pid` dado sobre
  la actualización de una `apuesta`.
  """
  def notify_update(pid, %Bid{} = bid) do
    GenServer.cast(pid, {:bid_updated, bid})
  end

  @doc """
  Notifica al comprador con el `pid` dado sobre
  la finalización de una `apuesta`.
  """
  def notify_termination(pid, %Bid{} = bid) do
    GenServer.cast(pid, {:bid_terminated, bid})
  end

  @doc """
  Verifica si el nombre del `comprador` se encuentra dentro
  de la lista de compradores dada.
  """
  def in?(pid, buyers_list) do
    GenServer.call(pid, {:name_is_in, buyers_list})
  end

  ########################
  ## Funciones Servidor ##
  ########################

  @doc """
  Inicializa el Worker con los datos del `comprador` como estado.
  """
  def init(%Buyer{} = buyer) do
    {:ok, buyer}
  end

  def start_link(buyer_data) do
    GenServer.start_link(__MODULE__, buyer_data, debug: [:statistics, :trace])
  end

  def handle_cast({:bid_created, bid}, %Buyer{ip: ip, tags: tags} = state) do
    if has_tags_in_common?(bid.tags, tags) do
      json_bid = make_body(:new, bid)
      url = ip <> "/bids/open"

      spawn(fn -> HTTPoison.post!(url, json_bid, [{"content-type", "application/json"}]) end)
    end

    {:noreply, state}
  end

  def handle_cast({:bid_updated, bid}, %Buyer{name: name, ip: ip} = state) do
    json_bid = make_body(:update, bid)
    url = ip <> "/bids/new_offer"

    res = HTTPoison.post!(url, json_bid, [{"content-type", "application/json"}])

    IO.inspect(res.body, label: "#{name} response body")

    {:noreply, state}
  end

  def handle_cast({:bid_terminated, bid}, %Buyer{name: name, ip: ip} = state) do
    json_bid = make_body(:termination, bid)
    url = ip <> "/bids/close"

    res = HTTPoison.post!(url, json_bid, [{"content-type", "application/json"}])

    IO.inspect(res.body, label: "#{name} response body")

    {:noreply, state}
  end

  def handle_call({:get_name}, _from, %Buyer{name: name} = state) do
    {:reply, name, state}
  end

  def handle_call({:name_is_in, list}, _from, %Buyer{name: name} = state) do
    {:reply, Enum.member?(list, name), state}
  end

  ##########################
  ## Funciones Auxiliares ##
  ##########################

  defp make_body(:new, %Bid{} = bid),
    do:
      Poison.encode!(%{
        id: bid.bid_id,
        json: bid.json,
        price: bid.price,
        tags: bid.tags,
        close_at: DateTime.from_unix!(bid.close_at)
      })

  defp make_body(:update, %Bid{} = bid),
    do:
      Poison.encode!(%{
        id: bid.bid_id,
        price: bid.price,
        winner: bid.winner,
        close_at: DateTime.from_unix!(bid.close_at)
      })

  defp make_body(:termination, %Bid{} = bid),
    do:
      Poison.encode!(%{
        id: bid.bid_id,
        price: bid.price,
        winner: bid.winner,
        close_at: DateTime.from_unix!(bid.close_at)
      })

  defp has_tags_in_common?(bid_tags, buyer_tags) do
    bid_tags
    |> Enum.any?(fn tag -> Enum.member?(buyer_tags, tag) end)
  end
end

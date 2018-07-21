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
  Devuelve el nombre del `comprador` con el `pid` dado.
  """
  def name(buyer_pid) do
    GenServer.call(buyer_pid, {:get_name})
  end

  @doc """
  Notifica al comprador con el `pid` dado sobre la creacion de
  una `apuesta`.
  """
  def notify_new(pid, bid) do
    GenServer.cast(pid, {:bid_new, bid})
  end

  @doc """
  Notifica al comprador con el `pid` dado sobre
  la actualización de una `apuesta`.
  """
  def notify_update(pid, bid) do
    GenServer.cast(pid, {:bid_updated, bid})
  end

  @doc """
  Notifica al comprador con el `pid` dado sobre
  la cancelación de una `apuesta`.
  """
  def notify_cancelled(pid, bid) do
    GenServer.cast(pid, {:bid_cancelled, bid})
  end

  @doc """
  Notifica al comprador con el `pid` dado sobre
  la finalización de una `apuesta`.
  """
  def notify_finalized(pid, bid) do
    GenServer.cast(pid, {:bid_finalized, bid})
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
    GenServer.start_link(__MODULE__, buyer_data)
  end

  def handle_cast({:bid_new, bid}, %Buyer{ip: ip, tags: tags} = state) do
    if has_tags_in_common?(bid.tags, tags) do
      body = make_body(bid)
      url = ip <> "/bids/open"

      spawn(fn -> send_request(body, url) end)
    end

    {:noreply, state}
  end

  def handle_cast({:bid_updated, bid}, %Buyer{ip: ip} = state) do
    body = make_body(bid)
    url = ip <> "/bids/new_offer"

    send_request(body, url)

    {:noreply, state}
  end

  def handle_cast({:bid_cancelled, bid}, %Buyer{ip: ip} = state) do
    body = make_body(bid)
    url = ip <> "/bids/close"

    send_request(body, url)

    {:noreply, state}
  end

  def handle_cast({:bid_finalized, bid}, %Buyer{ip: ip} = state) do
    body = make_body(bid)
    url = ip <> "/bids/close"

    send_request(body, url)

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

  defp make_body(bid) do
    Poison.encode!(encode_bid(bid))
  end

  defp send_request(body, url) do
    res = HTTPoison.post!(url, body, [{"content-type", "application/json"}])

    Logger.info("Response Body: #{inspect(res.body)}")
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

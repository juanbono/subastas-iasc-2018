defmodule Exchange.Buyers.Worker do
  use GenServer
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
    GenServer.cast(pid, {:bid_created, bid})
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
  la finalización de una `apuesta`.
  """
  def notify_termination(pid, bid) do
    GenServer.cast(pid, {:bid_terminated, bid})
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

  def handle_cast({:bid_created, bid}, %{"ip" => ip} = state) do
    if has_tags_in_common?(bid["tags"], state["tags"]) do
      json_bid = Poison.encode!(bid)
      res = HTTPoison.post!(ip <> "/notify", json_bid, [{"content-type", "application/json"}])
      IO.inspect(res.body, label: "response body")
    end

    {:noreply, state}
  end

  def handle_call({:get_name}, _from, %{name: name} = state) do
    {:reply, name, state}
  end

  defp has_tags_in_common?(bid_tags, buyer_tags) do
    bid_tags
    |> Enum.any?(fn tag -> Enum.member?(buyer_tags, tag) end)
  end
end

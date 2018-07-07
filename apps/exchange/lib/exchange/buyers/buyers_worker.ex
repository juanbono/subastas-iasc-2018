defmodule Exchange.Buyers.Worker do
  use GenServer
  alias Exchange.Buyers.Buyer

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

  def handle_cast({:new_bid, bid}, %{"ip" => ip} = state) do
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

  #######################
  ## Funciones Cliente ##
  #######################

  @doc """
  Devuelve el nombre del `comprador`.
  """
  def name(buyer_pid) do
    GenServer.call(buyer_pid, {:get_name})
  end

  @doc """
  Notifica al comprador con el `pid` dado sobre una `apuesta`.
  Para ello envia los datos de la apuesta al endpoint `/notify`
  del `comprador`.
  """
  def notify(pid, bid) do
    GenServer.cast(pid, {:new_bid, bid})
  end

  defp has_tags_in_common?(bid_tags, buyer_tags) do
    bid_tags
    |> Enum.any?(fn tag -> Enum.member?(buyer_tags, tag) end)
  end
end

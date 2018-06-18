defmodule Exchange.Buyers.Worker do
  use GenServer

  ########################
  ## Funciones Servidor ##
  ########################

  @doc """
  Inicializa el Worker con los datos del `comprador` como estado.
  """
  def init(buyer) do
    {:ok, buyer}
  end

  def start_link(buyer_data) do
    GenServer.start_link(__MODULE__, buyer_data, debug: [:statistics, :trace])
  end

  def handle_cast({:new_bid, bid}, %{"ip" => ip} = state) do
    # enviar la bid a la ip del comprador
    IO.inspect("Enviando bid con tags #{bid.tags} a: #{ip}\n")
    {:noreply, state}
  end

  #######################
  ## Funciones Cliente ##
  #######################

  @doc """
  Notifica al comprador con el `pid` dado sobre una `apuesta`.
  Para ello envia los datos de la apuesta al endpoint `/notify`
  del comprador.
  """
  def notify(pid, bid) do
    GenServer.cast(pid, {:new_bid, bid})
  end
end

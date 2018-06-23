defmodule Exchange.Bids.Worker do
  use GenServer

  ########################
  ## Funciones Servidor ##
  ########################

  @doc """
  Inicializa el Worker con los datos de la `apuesta` como estado.
  """
  def init(bid) do
    {:ok, bid}
  end

  def start_link(bid_data) do
    GenServer.start_link(__MODULE__, bid_data, debug: [:statistics, :trace])
  end

  #######################
  ## Funciones Cliente ##
  #######################
end

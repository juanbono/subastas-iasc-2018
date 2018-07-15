defmodule Exchange.Bids do
  alias Exchange.{Bids, Bids.Bid, Bids.Offer, Buyers}

  def process(:bid, params) do
    Bid.make(params)
    |> register()
  end

  def process(:offer, params) do
    Offer.make(params)
    |> apply()
  end

  def process(:cancel, params) do
    with {:ok, bid_id} <- Map.fetch(params, "bid_id"),
         :ok <- Bids.exists?(bid_id) do
      Bids.Worker.cancel(bid_id)
    else
      :invalid_id ->
        {:error, :invalid_id}

      :error ->
        {:error, "Bid ID must be present"}

      error ->
        {:error, error}
    end
  end

  @doc """
  Aplica una `oferta`. En caso de que el argumento pasado sea un error, lo devuelve.
  """
  def apply({:error, _} = error), do: error

  def apply(%Offer{} = offer) do
    updated_bid = Bids.Worker.update(offer)
    Buyers.notify_buyers(:update, updated_bid)

    {:ok, updated_bid}
  end

  @doc """
  Registra una apuesta en el sistema.
  """
  def register(%Bid{} = bid) do
    with {:ok, bid_state} <- Bids.Supervisor.register(bid) do
      Buyers.notify_buyers(:new, bid_state)
      {:ok, bid_state}
    else
      error ->
        error
    end
  end

  @doc """
  Devuelve una lista con los PIDs de las `apuestas` en el sistema.
  """
  def current_bids(), do: Bids.Supervisor.current_bids()

  @doc """
  Cantidad de `apuestas` en el sistema.
  """
  def number_of_bids(), do: Bids.Supervisor.number_of_bids()

  @doc """
  Devuelve los datos de la `apuesta` con el `id` dado.
  """
  def get_bid(bid_id) do
    current_bids()
    |> Enum.find({:error, :bid_not_found}, fn pid -> Bids.Worker.bid_id(pid) == bid_id end)
    |> (fn pid -> Bids.Worker.get_state(pid) end).()
  end

  @doc """
  Devuelve el PID de la `apuesta` el `id` dado.
  """
  def get_bid_pid(bid_id) do
    current_bids()
    |> Enum.find({:error, :bid_not_found}, fn pid -> Bids.Worker.bid_id(pid) == bid_id end)
  end

  @doc """
  Comprueba la existencia en el sistema de una `apuesta` con el `id` dado.
  """
  def exists?(bid_id) do
    bids =
      Bids.current_bids()
      |> Enum.map(fn bid_pid -> Bids.Worker.bid_id(bid_pid) end)

    if Enum.member?(bids, bid_id), do: :ok, else: :invalid_id
  end
end

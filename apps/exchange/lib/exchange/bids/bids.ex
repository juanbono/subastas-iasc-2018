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
    Buyers.notify_buyers(:new, updated_bid)

    {:ok, updated_bid.price}
  end

  @doc """
  Registra una apuesta en el sistema.
  """
  def register({:error, _} = error), do: error

  def register(%Bid{} = bid) do
    DynamicSupervisor.start_child(Bids.Supervisor, {Bids.Worker, bid})
    Buyers.notify_buyers(:new, bid)
    {:ok, number_of_bids()}
  end

  @doc """
  Devuelve una lista con los PIDs de las `apuestas` en el sistema.
  """
  def current_bids() do
    DynamicSupervisor.which_children(Bids.Supervisor)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  @doc """
  Cantidad de `apuestas` en el sistema.
  """
  def number_of_bids(), do: DynamicSupervisor.count_children(Bids.Supervisor).workers

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

    if Enum.member?(bids, bid_id), do: :ok, else: :invalid_bid_id
  end
end

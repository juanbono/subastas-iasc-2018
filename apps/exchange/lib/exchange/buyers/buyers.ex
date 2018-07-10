defmodule Exchange.Buyers do
  alias Exchange.{Buyers, Buyers.Buyer, Bids.Bid}

  @doc """
  Valida los datos dados y registra a un nuevo `comprador` con ellos.
  """
  def process(params) do
    Buyer.make(params)
    |> register()
  end

  @doc """
  Registra un comprador en el sistema. En caso de recibir un error, lo devuelve.
  """
  def register({:error, _} = error), do: error

  def register(%Buyer{} = buyer) do
    DynamicSupervisor.start_child(Buyers.Supervisor, {Buyers.Worker, buyer})
    {:ok, number_of_buyers()}
  end

  @doc """
  Devuelve una lista con los PIDs de los compradores en el sistema.
  """
  def current_buyers() do
    DynamicSupervisor.which_children(Buyers.Supervisor)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  @doc """
  Notifica a cada uno de los `compradores` en el sistema la creacion,
  actualización o finalización de una `apuesta`.
  """
  def notify_buyers(:new, %Bid{} = bid) do
    current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_new(pid, bid) end)
  end

  def notify_buyers(:update, %Bid{} = bid) do
    bid.interested_buyers
    |> names_to_pids()
    |> Enum.each(fn pid -> Buyers.Worker.notify_update(pid, bid) end)
  end

  def notify_buyers(:termination, %Bid{} = bid) do
    bid.interested_buyers
    |> names_to_pids()
    |> Enum.each(fn pid -> Buyers.Worker.notify_termination(pid, bid) end)
  end

  # TODO
  def notify_buyers(:cancel, %Bid{} = bid) do
  end

  @doc """
  Cantidad de compradores en el sistema.
  """
  def number_of_buyers() do
    DynamicSupervisor.count_children(Buyers.Supervisor).workers
  end

  def names_to_pids(buyer_names) do
    current_buyers()
    |> Enum.filter(fn pid -> Buyers.Worker.in?(pid, buyer_names) end)
  end

  @doc """
  Comprueba la existencia en el sistema de un `comprador` con nombre `name`.
  """
  def exists?(name) do
    buyers =
      Buyers.current_buyers()
      |> Enum.map(fn buyer -> Buyers.Worker.name(buyer) end)

    if Enum.member?(buyers, name), do: :ok, else: :invalid_name
  end
end

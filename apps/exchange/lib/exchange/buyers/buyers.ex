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
  Registra un comprador en el sistema.
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
  Notifica a cada `comprador` la creación de una nueva `apuesta`.
  """
  def notify_buyers(%Bid{} = bid) do
    current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify(pid, bid) end)
  end

  @doc """
  Cantidad de compradores en el sistema.
  """
  def number_of_buyers() do
    DynamicSupervisor.count_children(Buyers.Supervisor).workers
  end

  @doc """
  Comprueba la existencia en el sistema de un `comprador` con nombre `name`.
  """
  def exists?(name) do
    buyers =
      Buyers.current_buyers()
      |> Enum.map(fn buyer -> Buyers.Worker.name(buyer) end)

    if Enum.member?(buyers, name) do
      :invalid_name
    else
      :ok
    end
  end
end

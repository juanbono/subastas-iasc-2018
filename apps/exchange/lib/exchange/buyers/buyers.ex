defmodule Exchange.Buyers do
  alias Exchange.{Buyers, Buyers.Buyer}

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
  def register(buyer) do
    with {:ok, _pid} <- Buyers.Supervisor.register(buyer) do
      {:ok, number_of_buyers()}
    else
      error ->
        error
    end
  end

  def notify_buyers(:new, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_new(pid, bid) end)
  end

  def notify_buyers(:update, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_update(pid, bid) end)
  end

  def notify_buyers(:cancelled, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_cancelled(pid, bid) end)
  end

  def notify_buyers(:finalized, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_finalized(pid, bid) end)
  end

  @doc """
  Cantidad de compradores en el sistema.
  """
  defdelegate number_of_buyers, to: Buyers.Supervisor

  @doc """
  Comprueba la existencia en el sistema de un `comprador` con nombre `name`.
  """
  def exists?(name) do
    buyers =
      Buyers.Supervisor.current_buyers()
      |> Enum.map(fn buyer -> Buyers.Worker.name(buyer) end)

    if Enum.member?(buyers, name), do: :ok, else: :invalid_name
  end
end

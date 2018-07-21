defmodule Exchange.Buyers do
  @moduledoc """
  Modulo interfaz de los compradores. Explicar
  """
  alias Exchange.{Buyers, Buyers.Buyer}

  @doc """
  Valida los datos dados y registra a un nuevo `comprador` con ellos.
  """
  def process(params) do
    params
    |> Buyer.make()
    |> register()
  end

  @doc """
  Registra un comprador en el sistema. En caso de recibir un error, lo devuelve.
  """
  def register(buyer) do
    with {:ok, _pid} <- Exchange.Registry.start_buyer(buyer) do
      {:ok, number_of_buyers()}
    else
      {:error, _reason} = err ->
        err

      reason ->
        {:error, reason}
    end
  end

  def notify_buyers(:new, bid) do
    # Buyers.Supervisor.current_buyers()
    Buyers.SwarmSupervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_new(pid, bid) end)
  end

  def notify_buyers(:update, bid) do
    # Buyers.Supervisor.current_buyers()
    Buyers.SwarmSupervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_update(pid, bid) end)
  end

  def notify_buyers(:cancelled, bid) do
    # Buyers.Supervisor.current_buyers()
    Buyers.SwarmSupervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_cancelled(pid, bid) end)
  end

  def notify_buyers(:finalized, bid) do
    # Buyers.Supervisor.current_buyers()
    Buyers.SwarmSupervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_finalized(pid, bid) end)
  end

  @doc """
  Cantidad de compradores en el sistema.
  """
  defdelegate number_of_buyers, to: Buyers.SwarmSupervisor

  @doc """
  Comprueba la existencia en el sistema de un `comprador` con nombre `name`.
  """
  def exists?(name) do
    buyers =
      Buyers.SwarmSupervisor.current_buyers()
      |> Enum.map(fn buyer -> Buyers.Worker.name(buyer) end)

    if Enum.member?(buyers, name), do: :ok, else: :invalid_name
  end
end

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
    with {:ok, pid} <- Exchange.Registry.start_buyer(buyer) do
      Exchange.Bids.Supervisor.broadcast_new_buyer(pid)

      {:ok, number_of_buyers()}
    else
      {:error, _reason} = err ->
        err

      reason ->
        {:error, reason}
    end
  end

  @doc """
  Dado un `evento` ocurrido a una `apuesta`, notifica a todos los compradores de su ocurrencia.
  Cada comprador individualmente decide si hara algo al respecto o no.
  """
  def notify_buyers(:new, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_new(pid, bid) end)
  end

  def notify_buyers(:update, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_update(pid, bid) end)
  end

  def notify_buyers(:finalized, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.bid_finalized(pid, bid) end)
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

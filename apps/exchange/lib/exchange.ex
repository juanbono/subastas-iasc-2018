defmodule Exchange do
  alias Exchange.{Buyers, Bids}

  @doc """
  Crea un `comprador` con los datos pasados como parametro.
  """
  def create_buyer(buyer_data) do
    Buyers.process(buyer_data)
  end

  @doc """
  Crea una `apuesta` con los datos pasados como parametro.
  """
  def create_bid(bid_data) do
    Bids.process(:bid, bid_data)
  end

  @doc """
  Actualiza una `apuesta` con los datos pasados como parametro.
  """
  def update_bid(offer_data) do
    Bids.process(:offer, offer_data)
  end

  @doc """
  Cancel una `apuesta` con los datos pasados como parametro.
  """
  def cancel_bid(offer_data) do
    Bids.process(:cancel, offer_data)
  end

  @doc """
  Notifica a cada uno de los `compradores`
  en el sistema la creacion de una `apuesta`.
  """
  def notify_bid_creation(bid) do
    Buyers.notify_buyers(:new, bid)
  end

  @doc """
  Notifica a cada uno de los `compradores`
  en el sistema la actualización de una `apuesta`.
  """
  def notify_bid_update(bid) do
    Buyers.notify_buyers(:update, bid)
  end

  @doc """
  Notifica a cada uno de los `compradores`
  en el sistema la cancelled de una `apuesta`.
  """
  def notify_bid_cancelled(bid) do
    Buyers.notify_buyers(:cancelled, bid)
  end

  @doc """
  Notifica a cada uno de los `compradores`
  en el sistema la finalización de una `apuesta`.
  """
  def notify_bid_finalized(bid) do
    Buyers.notify_buyers(:finalized, bid)
  end

  @doc """
  Cantidad de `compradores` en el sistema.
  """
  defdelegate number_of_buyers, to: Buyers

  @doc """
  Cantidad de `apuestas` en el sistema.
  """
  defdelegate number_of_bids, to: Bids
end

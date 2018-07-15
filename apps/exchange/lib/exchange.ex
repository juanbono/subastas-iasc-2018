defmodule Exchange do
  alias Exchange.Interfaces.{Buyers, Bids}

  @doc """
  Crea un `comprador` con los datos pasados como parametro.
  """
  def create_buyer(buyer_data), do: Buyers.Local.process(buyer_data)

  @doc """
  Crea una `apuesta` con los datos pasados como parametro.
  """
  def create_bid(bid_data), do: Bids.Local.process(:bid, bid_data)

  @doc """
  Actualiza una `apuesta` con los datos pasados como parametro.
  """
  def update_bid(offer_data), do: Bids.Local.process(:offer, offer_data)

  @doc """
  Cancel una `apuesta` con los datos pasados como parametro.
  """
  def cancel_bid(offer_data), do: Bids.Local.process(:cancel, offer_data)

  @doc """
  Notifica a cada uno de los `compradores`
  en el sistema la creacion de una `apuesta`.
  """
  def notify_bid_creation(bid), do: Buyers.Local.notify_buyers(:new, bid)

  @doc """
  Notifica a cada uno de los `compradores`
  en el sistema la actualización de una `apuesta`.
  """
  def notify_bid_update(bid), do: Buyers.Local.notify_buyers(:update, bid)

  @doc """
  Notifica a cada uno de los `compradores`
  en el sistema la cancelled de una `apuesta`.
  """
  def notify_bid_cancelled(bid), do: Buyers.Local.notify_buyers(:cancelled, bid)

  @doc """
  Notifica a cada uno de los `compradores`
  en el sistema la finalización de una `apuesta`.
  """
  def notify_bid_finalized(bid), do: Buyers.Local.notify_buyers(:finalized, bid)

  @doc """
  Cantidad de `compradores` en el sistema.
  """
  def number_of_buyers(), do: Buyers.Local.number_of_buyers()

  @doc """
  Cantidad de `apuestas` en el sistema.
  """
  def number_of_bids(), do: Bids.Local.number_of_bids()
end

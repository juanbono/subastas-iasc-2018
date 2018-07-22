defmodule Exchange.Bids.Interfaces.Buyers.Local do
  @moduledoc """
  Modulo con las funciones relativas a los compradores que son utilizadas
  por otros modulos. La implementacion de las mismas utiliza modulos locales.
  """
  defdelegate notify_buyers(event, bid), to: Exchange.Buyers

  defdelegate exists?(buyer_name), to: Exchange.Buyers
end

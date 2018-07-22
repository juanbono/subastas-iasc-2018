defmodule Exchange.Interfaces.Buyers.Local do
  @moduledoc """
  Modulo con las funciones relativas a los compradores que son utilizadas
  por otros modulos. La implementacion de las mismas utiliza modulos locales.
  """
  defdelegate process(buyer_data), to: Exchange.Buyers

  defdelegate notify_buyers(event, bid), to: Exchange.Buyers

  defdelegate number_of_buyers, to: Exchange.Buyers
end

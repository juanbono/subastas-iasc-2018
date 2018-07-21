defmodule Exchange.Interfaces.Bids.Local do
  @moduledoc """
  Modulo con las funciones relativas a las apuestas que son utilizadas
  por otros modulos. La implementacion de las mismas utiliza modulos locales.
  """
  defdelegate process(operation, offer_data), to: Exchange.Bids

  defdelegate number_of_bids, to: Exchange.Bids
end

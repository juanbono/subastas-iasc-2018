defmodule Exchange.Interfaces.Bids.Local do
  defdelegate process(operation, offer_data), to: Exchange.Bids

  defdelegate number_of_bids, to: Exchange.Bids
end

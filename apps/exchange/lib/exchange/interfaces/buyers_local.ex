defmodule Exchange.Interfaces.Buyers.Local do
  defdelegate process(buyer_data), to: Exchange.Buyers

  defdelegate notify_buyers(event, bid), to: Exchange.Buyers

  defdelegate number_of_buyers, to: Exchange.Buyers
end

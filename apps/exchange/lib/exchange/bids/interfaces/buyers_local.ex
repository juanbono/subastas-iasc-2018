defmodule Exchange.Bids.Interfaces.Buyers.Local do
  defdelegate notify_buyers(event, bid), to: Exchange.Buyers

  defdelegate exists?(buyer_name), to: Exchange.Buyers
end

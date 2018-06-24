defmodule Client.OfferLogic do
  def process(body_params) do
    if offer?(body_params) do
      send_offer(
        url(body_params["id"]),
        offer_params(body_params)
      )
    end
  end

  def offer?(body_params) do
    Enum.member?(body_params["tags"], "zapatos") && body_params["price"] < 100
  end

  def url(id) do
    "http://localhost:4000/bids/#{id}/offers"
  end

  def offer_params(body_params) do
    Poison.encode!(%{
      price: (body_params["price"] + 10),
      user_id: 45
    })
  end

  def send_offer(url, params) do
    HTTPoison.post!(url, params, [{"content-type", "application/json"}])
  end
end

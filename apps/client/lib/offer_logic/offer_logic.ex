defmodule Client.OfferLogic do
  def process(body_params) do
    if offer?(body_params) do
      send_offer(
        url(),
        offer_params(body_params)
      )
    end
  end

  def offer?(body_params) do
    IO.inspect(body_params, label: "articulo interesante recibido")

    IO.inspect(
      Enum.member?(body_params["tags"], "zapatos") && body_params["price"] < 100,
      label: "oferto?"
    )
  end

  def url() do
    "http://localhost:4000/bids/offer"
  end

  def offer_params(body_params) do
    Poison.encode!(%{
      # change the buyer name
      buyer: "A",
      price: body_params["price"] + 10,
      bid_id: body_params["id"]
    })
  end

  def send_offer(url, params) do
    IO.inspect(params, label: "voy a enviar estos parametros \n")
    res = HTTPoison.post!(url, params, [{"content-type", "application/json"}])
    IO.inspect(res, label: "recibido luego de ofertar")
  end
end

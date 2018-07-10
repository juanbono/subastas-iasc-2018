defmodule Client do
  @moduledoc """
  Sample client.
  """
  require Integer

  def handle_open(bid_data) do
    IO.inspect(bid_data, label: "Nueva apuesta")

    if make_offer?(bid_data) do
      offer = offer_params(bid_data)
      send_offer(url(), offer)
    end
  end

  def handle_offer(bid_data) do
    IO.inspect(bid_data, label: "Apuesta actualizada")

    if make_offer?(bid_data) do
      offer = offer_params(bid_data)
      send_offer(url(), offer)
    end
  end

  def handle_close(bid_data) do
    IO.inspect(bid_data, label: "Apuesta terminada")
    IO.inspect(bid_data["winner"], label: "Ganador")
  end

  defp client_name() do
    Node.self()
    |> Atom.to_string()
    |> String.first()
  end

  defp make_offer?(bid_data) do
    is_good_offer = Enum.member?(bid_data["tags"], "zapatos") && bid_data["price"] < 100
    is_good_offer && Integer.is_even(:rand.uniform(2))
  end

  defp offer_params(bid_data) do
    Poison.encode!(%{
      buyer: client_name(),
      price: bid_data["price"] + 1,
      bid_id: bid_data["id"]
    })
  end

  defp send_offer(url, offer) do
    IO.inspect(offer, label: "voy a enviar estos parametros \n")
    res = HTTPoison.post!(url, offer, [{"content-type", "application/json"}])
    IO.inspect(res, label: "recibido luego de ofertar")
  end

  defp url() do
    "http://localhost:4000/bids/offer"
  end
end

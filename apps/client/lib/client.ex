defmodule Client do
  @moduledoc """
  Sample client.
  """
  require Integer
  require Logger

  @url "http://localhost:4000/bids/offer"

  def handle_open(bid_data) do
    Logger.info("Nueva apuesta: #{inspect(bid_data)}")

    if make_offer?(bid_data) do
      bid_data
      |> offer_params()
      |> send_offer(@url)
    end
  end

  def handle_offer(bid_data) do
    Logger.info("Apuesta actualizada: #{inspect(bid_data)}")

    if make_offer?(bid_data) do
      bid_data
      |> offer_params()
      |> send_offer(@url)
    end
  end

  def handle_close(bid_data) do
    Logger.info("Apuesta terminada: #{inspect(bid_data)}")
    Logger.info("Estado: #{inspect(bid_data["state"])}")
    Logger.info("Ganador: #{inspect(bid_data["winner"])}")
  end

  defp client_name() do
    Node.self()
    |> Atom.to_string()
    |> String.first()
  end

  defp make_offer?(bid_data) do
    is_good_offer = Enum.member?(bid_data["tags"], "zapatos") && bid_data["price"] < 10000
    # && Integer.is_even(:rand.uniform(2))
    is_good_offer
  end

  defp offer_params(bid_data) do
    Poison.encode!(%{
      buyer: client_name(),
      price: bid_data["price"] + 1,
      bid_id: bid_data["id"]
    })
  end

  defp send_offer(offer, url) do
    Logger.info("Voy a enviar estos parametros: #{inspect(offer)}")
    spawn(fn -> HTTPoison.post!(url, offer, [{"content-type", "application/json"}]) end)
  end
end

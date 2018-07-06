defmodule Exchange.Bids.Offer do
  @moduledoc """

  """
  @enforce_keys [:bid_id, :price, :buyer, :timestamp]
  defstruct bid_id: nil, price: 0, buyer: "", timestamp: 0

  def make(params) do
    empty()
    |> check_bid_id(params)
    |> check_buyer(params)
    |> check_price(params)
    |> check_timestamp(params)
  end

  @doc """
  Devuelve una `oferta` vacia.
  """
  def empty(), do: %__MODULE__{bid_id: nil, price: nil, buyer: nil, timestamp: nil}

  defp check_bid_id(offer, {:error, _} = error), do: error

  defp check_bid_id(offer, params) do
  end

  defp check_price({:error, _} = error), do: error

  # asumir que aca ya tengo el precio real de la oferta
  # para poder comparar si es menor o mayor que el actual.
  defp check_price(offer, params) do
    case Map.fetch(params, "price") do
      {:ok, price} when price >= 0 ->
        Map.put(offer, :price, price)

      _error ->
        {:error, :invalid_price}
    end
  end

  defp check_buyer({:error, _} = error), do: error

  defp check_buyer(offer, params) do
  end

  defp check_timestamp({:error, _} = error), do: error

  defp check_timestamp(offer, params) do
  end
end

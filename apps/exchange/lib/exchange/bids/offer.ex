defmodule Exchange.Bids.Offer do
  @moduledoc """
  Modelo de una oferta. Las ofertas son actualizaciones que se realizan a las `apuestas`.
  #### Atributos:
  - `bid_id` :: string, ID de la apuesta, entregado por la Exchange en formato UUIDv4.
  - `price`  :: float, Precio de la oferta. Debe ser mayor al precio actual de la `subasta`.
  - `buyer`  :: string, Nombre del `comprador` que esta realizando la oferta.
  """
  alias Exchange.{Bids, Bids.Bid, Bids.Interfaces.Buyers}

  @enforce_keys [:bid_id, :price, :buyer]
  defstruct bid_id: nil, price: 0, buyer: ""

  def make(params) do
    empty()
    |> check_bid_id(params)
    |> check_buyer(params)
    |> check_price(params)
  end

  @doc """
  Devuelve una `oferta` vacia.
  """
  def empty(), do: %__MODULE__{bid_id: nil, price: nil, buyer: nil}

  defp check_bid_id({:error, _} = error, _params), do: error

  defp check_bid_id(offer, params) do
    with {:ok, bid_id} <- Map.fetch(params, "bid_id"),
         :ok <- Bids.exists?(bid_id) do
      Map.put(offer, :bid_id, bid_id)
    else
      :invalid_id ->
        {:error, :invalid_id}

      :error ->
        {:error, "Bid ID must be present"}

      error ->
        {:error, error}
    end
  end

  defp check_price({:error, _} = error, _params), do: error

  defp check_price(offer, params) do
    with {:ok, %Bid{price: current_price}} <- Bids.get_bid(params["bid_id"]),
         {:ok, price} when is_number(price) and price > current_price <-
           Map.fetch(params, "price") do
      Map.put(offer, :price, price)
    else
      {:error, :bid_not_found} = not_found_err ->
        not_found_err

      :error ->
        {:error, "Price must be present"}

      _error ->
        {:error, :invalid_price}
    end
  end

  defp check_buyer({:error, _} = error, _params), do: error

  defp check_buyer(offer, params) do
    with {:ok, buyer_name} when is_binary(buyer_name) <- Map.fetch(params, "buyer"),
         :ok <- Buyers.Local.exists?(buyer_name) do
      Map.put(offer, :buyer, buyer_name)
    else
      :invalid_name ->
        {:error, :invalid_name}

      :error ->
        {:error, "Buyer must be present"}

      error ->
        error
    end
  end
end

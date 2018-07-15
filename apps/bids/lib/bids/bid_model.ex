defmodule Bids.Model.Bid do
  @moduledoc """

  """

  @enforce_keys [:price, :close_at, :json, :tags, :bid_id, :interested_buyers]
  defstruct bid_id: nil,
            price: nil,
            close_at: nil,
            json: nil,
            tags: nil,
            interested_buyers: nil,
            winner: nil,
            state: nil

  @doc """
  Smart constructor para las apuestas.
  Maneja toda la lógica de validación
  para construir una apuesta válida.
  """
  def make(params) do
    empty()
    |> check_price(params)
    |> check_close_at(params)
    |> check_json(params)
    |> check_tags(params)
  end

  @doc """
  Devuelve una `apuesta` vacia.
  """
  def empty(),
    do: %__MODULE__{
      bid_id: nil,
      price: nil,
      close_at: nil,
      json: nil,
      tags: nil,
      interested_buyers: nil,
      state: "new"
    }

  def to_map(bid) do
    %{
      id: bid.bid_id,
      json: bid.json,
      price: bid.price,
      tags: bid.tags,
      winner: bid.winner,
      close_at: bid.close_at,
      state: bid.state
    }
  end

  defp check_price({:error, _reason} = err, _params), do: err

  defp check_price(bid, params) do
    case Map.fetch(params, "price") do
      {:ok, price} when is_number(price) and price >= 0 ->
        Map.put(bid, :price, price)

      :error ->
        {:error, "Price must be present"}

      _error ->
        {:error, :invalid_price}
    end
  end

  defp check_close_at({:error, _reason} = err, _params), do: err

  defp check_close_at(bid, params) do
    now_to_unix = DateTime.to_unix(DateTime.utc_now()) + 5

    with {:ok, close_at} when is_integer(close_at) and close_at > now_to_unix <-
           Map.fetch(params, "close_at"),
         {:ok, close_at_date} <- DateTime.from_unix(close_at) do
      Map.put(bid, :close_at, close_at_date)
    else
      :error ->
        {:error, "Close at must be present"}

      _err ->
        {:error, :invalid_close_at}
    end
  end

  defp check_json({:error, _reason} = err, _params), do: err

  defp check_json(bid, params) do
    with {:ok, json} when is_map(json) <- Map.fetch(params, "json") do
      Map.put(bid, :json, json)
    else
      :error ->
        {:error, "Json must be present"}

      _error ->
        {:error, :invalid_json}
    end
  end

  defp check_tags({:error, _reason} = err, _params), do: err

  defp check_tags(bid, params) do
    case Map.fetch(params, "tags") do
      {:ok, tags} when is_list(tags) ->
        Map.put(bid, :tags, tags)

      :error ->
        {:error, "Tags must be present"}

      _error ->
        {:error, :invalid_tags}
    end
  end
end

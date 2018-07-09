defmodule Exchange.Bids.Bid do
  @moduledoc """

  """

  @enforce_keys [:price, :duration, :json, :tags, :bid_id, :interested_buyers]
  defstruct bid_id: nil,
            price: nil,
            duration: nil,
            json: nil,
            tags: nil,
            interested_buyers: nil,
            winner: nil

  @doc """
  Smart constructor para las apuestas.
  Maneja toda la lógica de validación
  para construir una apuesta válida.
  """
  def make(params) do
    empty()
    |> check_price(params)
    |> check_duration(params)
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
      duration: nil,
      json: nil,
      tags: nil,
      interested_buyers: nil
    }

  defp check_price({:error, _reason} = err, _params), do: err

  defp check_price(bid, params) do
    case Map.fetch(params, "price") do
      {:ok, price} when price >= 0 ->
        Map.put(bid, :price, price)

      _error ->
        {:error, :invalid_price}
    end
  end

  defp check_duration({:error, _reason} = err, _params), do: err

  defp check_duration(bid, params) do
    case Map.fetch(params, "duration") do
      {:ok, duration} when duration > 0 ->
        Map.put(bid, :duration, duration)

      _error ->
        {:error, :invalid_duration}
    end
  end

  defp check_json({:error, _reason} = err, _params), do: err

  defp check_json(bid, params) do
    with {:ok, json} <- Map.fetch(params, "json") do
      Map.put(bid, :json, json)
    else
      _error ->
        {:error, :invalid_json}
    end
  end

  defp check_tags({:error, _reason} = err, _params), do: err

  defp check_tags(bid, params) do
    case Map.fetch(params, "tags") do
      {:ok, tags} when is_list(tags) ->
        Map.put(bid, :tags, tags)

      _error ->
        {:error, :invalid_tags}
    end
  end
end

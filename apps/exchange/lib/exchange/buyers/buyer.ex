defmodule Exchange.Buyers.Buyer do
  @moduledoc """

  """
  alias Exchange.Buyers

  @enforce_keys [:ip, :name, :tags]
  defstruct ip: "", name: "", tags: []

  @doc """
  Smart constructor para las apuestas.
  Maneja toda la lógica de validación
  para construir una apuesta válida.
  """
  def make(params) do
    empty()
    |> check_name(params)
    |> check_ip(params)
    |> check_tags(params)
  end

  @doc """
  Crea un `comprador` vacio.
  """
  def empty(), do: %__MODULE__{ip: nil, name: nil, tags: nil}

  defp check_ip({:error, _reason} = err, _params), do: err

  defp check_ip(buyer, params) do
    case Map.fetch(params, "ip") do
      {:ok, ip} when is_binary(ip) ->
        Map.put(buyer, :ip, ip)

      _error ->
        {:error, :invalid_ip}
    end
  end

  defp check_name({:error, _reason} = err, _params), do: err

  defp check_name(buyer, params) do
    with {:ok, name} when is_binary(name) <- Map.fetch(params, "name"),
         :ok <- Buyers.exists?(name) do
      Map.put(buyer, :name, name)
    else
      :invalid_name ->
        {:error, :invalid_name}

      # podemos manejar aca el caso en el que el server no tiene espacio?
      error ->
        error
    end
  end

  defp check_tags({:error, _reason} = err, _params), do: err

  defp check_tags(buyer, params) do
    case Map.fetch(params, "tags") do
      {:ok, tags} when is_list(tags) ->
        Map.put(buyer, :tags, tags)

      _error ->
        {:error, :invalid_tags}
    end
  end
end
defmodule Exchange.Buyers.Buyer do
  @moduledoc """
  Modelo de un comprador.
  #### Atributos:
  - `ip`   :: string, Direccion IP del comprador.
  - `name` :: string, Nombre del comprador, debe ser unico.
  - `tags` :: [string], Lista de tags que le interesan al comprador. Este solo sera notificado por las apuestas que le interesan.
  """
  alias Exchange.Buyers

  @enforce_keys [:ip, :name, :tags]
  defstruct ip: "", name: "", tags: []

  @doc """
  Smart constructor para los compradores.
  Maneja toda la lógica de validación
  para construir un comprador válido.
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

  ##################
  ## Validaciones ##
  ##################

  defp check_ip({:error, _reason} = err, _params), do: err

  defp check_ip(buyer, params) do
    case Map.fetch(params, "ip") do
      {:ok, ip} when is_binary(ip) ->
        Map.put(buyer, :ip, ip)

      :error ->
        {:error, "IP must be present"}

      _error ->
        {:error, :invalid_ip}
    end
  end

  defp check_name({:error, _reason} = err, _params), do: err

  defp check_name(buyer, params) do
    with {:ok, name} when is_binary(name) <- Map.fetch(params, "name"),
         :invalid_name <- Buyers.exists?(name) do
      Map.put(buyer, :name, name)
    else
      :invalid_name ->
        {:error, :invalid_name}

      _error ->
        {:error, "Name must be present"}
    end
  end

  defp check_tags({:error, _reason} = err, _params), do: err

  defp check_tags(buyer, params) do
    case Map.fetch(params, "tags") do
      {:ok, tags} when is_list(tags) ->
        Map.put(buyer, :tags, tags)

      :error ->
        {:error, "Tags must be present"}

      _error ->
        {:error, :invalid_tags}
    end
  end
end

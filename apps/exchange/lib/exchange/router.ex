defmodule Exchange.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  post "/buyers" do
    case Exchange.Buyers.process(conn.body_params) do
      {:ok, count} ->
        send_resp(conn, 200, "Buyer added succesfully! Buyers: #{count}.\n")

      {:error, :name_not_unique} ->
        send_resp(conn, 400, "Error: The name is already in use.\n")

      {:error, :no_space} ->
        send_resp(conn, 400, "Error: There is no space in the exchange.\n")

      {:error, :invalid_json} ->
        send_resp(conn, 400, "Error: Invalid JSON.\n")

      {:error, reason} ->
        send_resp(conn, 400, "Error: #{reason}\n")
    end
  end

  post "/bids" do
    case Exchange.Bids.process(:bid, conn.body_params) do
      {:ok, count} ->
        send_resp(conn, 200, "Bid added succesfully! Bids: #{count}.\n")

      {:error, :invalid_duration} ->
        send_resp(conn, 400, "Error: Invalid duration.\n")

      {:error, :no_space} ->
        send_resp(conn, 400, "Error: There is no space in the exchange.\n")

      {:error, reason} ->
        send_resp(conn, 400, "Error: #{reason}\n")
    end
  end

  post "/bids/:id/offer" do
    case Exchange.Bids.process(:offer, conn.body_params) do
      {:ok, new_price} ->
        send_resp(conn, 200, "New price accepted. Price: #{new_price}.\n")

      {:error, _reason} ->
        send_resp(conn, 400, "Invalid bid.\n")
    end
  end

  match _ do
    error_msg = "Wrong endpoint.\n Valid endpoints: '/buyers' and '/bids'\n"
    send_resp(conn, 404, error_msg)
  end

  ######################
  ## Helper Functions ##
  ######################

  @doc """
  Un comprador válido debe proporcionar:
    * Un `nombre` lógico.
    * Su dirección `IP`.
    * Una lista con los `tags` de su interés.
  """
  def is_valid_buyer?(conn) do
    [&has_name/1, &has_ip/1, &has_tags/1]
    |> is_valid?(conn)
  end

  @doc """
  Una apuesta válida debe tener:
    * Una lista de `tags`.
    * Su `precio` base (que puede ser 0).
    * La `duración` máxima de la subasta (expresada en ms).
    * Un `JSON` con la información del articulo.
  """
  def is_valid_bid?(conn) do
    [&has_tags/1, &has_price/1, &has_duration/1, &has_json/1]
    |> is_valid?(conn)
  end

  def is_valid_offer?(id, conn) do
    valid_id = has_valid_id(id)

    valid_conn =
      [&has_name/1, &has_price/1]
      |> is_valid?(conn)

    valid_id && valid_conn
  end

  defp is_valid?(predicates, conn),
    do: Enum.all?(predicates, fn pred -> pred.(conn) end)

  defp has_valid_id(id), do: Exchange.Bids.exists?(id)
  defp has_name(conn), do: Map.has_key?(conn.body_params, "name")
  defp has_ip(conn), do: Map.has_key?(conn.body_params, "ip")
  defp has_tags(conn), do: Map.has_key?(conn.body_params, "tags")
  defp has_price(conn), do: Map.has_key?(conn.body_params, "price")
  defp has_duration(conn), do: Map.has_key?(conn.body_params, "duration")
  defp has_json(conn), do: Map.has_key?(conn.body_params, "json")
end

defmodule Exchange.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  post "/buyers" do
    case Exchange.Buyers.process(conn.body_params) do
      {:ok, count} ->
        send_json_resp(conn, :created, "Buyer added succesfully! Buyers: #{count}")

      {:error, :name_not_unique} ->
        send_json_resp(conn, :unprocessable_entity, "The name is already in use")

      # TODO: generalizar este caso en todos los endpoints
      {:error, :no_space} ->
        send_json_resp(conn, :internal_server_error, "There is no space in the exchange")

      # TODO: generalizar este caso en todos los endpoints
      {:error, :invalid_json} ->
        send_json_resp(conn, :bad_request, "Invalid request")

      {:error, reason} ->
        send_json_resp(conn, :bad_request, reason)
    end
  end

  post "/bids" do
    case Exchange.Bids.process(:bid, conn.body_params) do
      {:ok, count} ->
        send_json_resp(conn, :created, "Bid added succesfully! Bids: #{count}")

      {:error, :name_not_unique} ->
        send_json_resp(conn, :unprocessable_entity, "Invalid duration")

      # TODO: generalizar este caso en todos los endpoints
      {:error, :no_space} ->
        send_json_resp(conn, :internal_server_error, "There is no space in the exchange")

      # TODO: generalizar este caso en todos los endpoints
      {:error, :invalid_json} ->
        send_json_resp(conn, :bad_request, "Invalid request")

      {:error, reason} ->
        send_json_resp(conn, :bad_request, reason)
    end
  end

  post "/bids/:id/offer" do
    case Exchange.Bids.process(:offer, conn.body_params) do
      {:ok, new_price} ->
        send_json_resp(conn, :ok, "New price accepted. Price: #{new_price}")

      {:error, _reason} ->
        send_json_resp(conn, :bad_request, "Invalid bid")
    end
  end

  match _ do
    send_json_resp(conn, :not_found, "Valid endpoints: '/buyers' and '/bids'")
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

  # TODO: mandar a un modulo aparte
  def send_json_resp(conn, :ok, body) do
    conn |> send_json_resp_by(200, %{
      message: body
    })
  end

  def send_json_resp(conn, :created, body) do
    conn |> send_json_resp_by(201, %{
      message: body
    })
  end

  def send_json_resp(conn, :bad_request, body) do
    conn |> send_json_resp_by(400, %{
      error: body
    })
  end

  def send_json_resp(conn, :not_found, body) do
    conn |> send_json_resp_by(404, %{
      error: body
    })
  end

  def send_json_resp(conn, :unprocessable_entity, body) do
    conn |> send_json_resp_by(422, %{
      error: body
    })
  end

  def send_json_resp(conn, :internal_server_error, body) do
    conn |> send_json_resp_by(500, %{
      error: body
    })
  end

  def send_json_resp_by(conn, status, body) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Poison.encode!(body))
  end
end

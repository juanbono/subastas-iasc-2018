defmodule Exchange.Router do
  use Plug.Router
  alias Exchange

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  post "/buyers" do
    Exchange.create_buyer(conn.body_params)
    |> handle_response(:buyers_endpoint, conn)
  end

  post "/bids" do
    Exchange.create_bid(conn.body_params)
    |> handle_response(:bids_endpoint, conn)
  end

  post "/bids/offer" do
    Exchange.update_bid(conn.body_params)
    |> handle_response(:new_offer_endpoint, conn)
  end

  match _ do
    send_json_resp(conn, :not_found, "Valid endpoints: '/buyers' and '/bids'")
  end

  ######################
  ## Helper Functions ##
  ######################

  defp handle_response(result, :bids_endpoint, conn) do
    case result do
      {:ok, count} ->
        send_json_resp(conn, :created, "Bid added succesfully! Bids: #{count}")

      {:error, :invalid_close_at} ->
        send_json_resp(conn, :bad_request, "Invalid close at")

      # TODO: generalizar este caso en todos los endpoints
      {:error, :invalid_json} ->
        send_json_resp(conn, :bad_request, "Invalid request")

      {:error, :invalid_tags} ->
        send_json_resp(conn, :bad_request, "Invalid tags")

      {:error, reason} ->
        send_json_resp(conn, :bad_request, reason)
    end
  end

  defp handle_response(result, :buyers_endpoint, conn) do
    case result do
      {:ok, count} ->
        send_json_resp(conn, :created, "Buyer added succesfully! Buyers: #{count}")

      {:error, :invalid_name} ->
        send_json_resp(conn, :bad_request, "The name is already in use")

      # TODO: generalizar este caso en todos los endpoints
      {:error, :invalid_ip} ->
        send_json_resp(conn, :bad_request, "Invalid IP")

      # TODO: generalizar este caso en todos los endpoints
      {:error, :invalid_tags} ->
        send_json_resp(conn, :bad_request, "Invalid tags")

      {:error, reason} ->
        send_json_resp(conn, :bad_request, reason)
    end
  end

  defp handle_response(result, :new_offer_endpoint, conn) do
    case result do
      {:ok, new_price} ->
        send_json_resp(conn, :ok, "New price accepted. Price: #{new_price}")

      {:error, reason} ->
        send_json_resp(conn, :bad_request, "Invalid bid: #{reason}")
    end
  end

  # TODO: mandar a un modulo aparte
  def send_json_resp(conn, :ok, body) do
    conn
    |> send_json_resp_by(200, %{
      message: body
    })
  end

  def send_json_resp(conn, :created, body) do
    conn
    |> send_json_resp_by(201, %{
      message: body
    })
  end

  def send_json_resp(conn, :bad_request, body) do
    conn
    |> send_json_resp_by(400, %{
      error: body
    })
  end

  def send_json_resp(conn, :not_found, body) do
    conn
    |> send_json_resp_by(404, %{
      error: body
    })
  end

  def send_json_resp(conn, :unprocessable_entity, body) do
    conn
    |> send_json_resp_by(422, %{
      error: body
    })
  end

  def send_json_resp(conn, :internal_server_error, body) do
    conn
    |> send_json_resp_by(500, %{
      error: body
    })
  end

  def send_json_resp_by(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(body))
  end
end

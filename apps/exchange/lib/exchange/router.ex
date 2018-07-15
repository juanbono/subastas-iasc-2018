defmodule Exchange.Router do
  use Plug.Router

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

  post "/bids/cancel" do
    Exchange.cancel_bid(conn.body_params)
    |> handle_response(:cancel_offer_endpoint, conn)
  end

  match _ do
    send_json_resp(conn, :not_found, "Valid endpoints: '/buyers' and '/bids'")
  end

  ######################
  ## Helper Functions ##
  ######################

  defp handle_response(result, :buyers_endpoint, conn) do
    case result do
      {:ok, count} ->
        send_json_message(conn, :created, "Buyer added succesfully! Buyers: #{count}")

      {:error, :invalid_name} ->
        send_json_error(conn, :bad_request, "The name is already in use")

      # TODO: generalizar este caso en todos los endpoints
      {:error, :invalid_ip} ->
        send_json_error(conn, :bad_request, "Invalid IP")

      # TODO: generalizar este caso en todos los endpoints
      {:error, :invalid_tags} ->
        send_json_error(conn, :bad_request, "Invalid tags")

      {:error, reason} ->
        send_json_error(conn, :bad_request, reason)
    end
  end

  defp handle_response(result, :bids_endpoint, conn) do
    case result do
      {:ok, bid} ->
        send_json_resp(conn, :created, encode_bid(bid))

      {:error, :invalid_close_at} ->
        send_json_error(conn, :bad_request, "Invalid close at")

      # TODO: generalizar este caso en todos los endpoints
      {:error, :invalid_json} ->
        send_json_error(conn, :bad_request, "Invalid request")

      {:error, :invalid_tags} ->
        send_json_error(conn, :bad_request, "Invalid tags")

      {:error, reason} ->
        send_json_error(conn, :bad_request, reason)
    end
  end

  defp handle_response(result, :cancel_offer_endpoint, conn) do
    case result do
      {:ok} ->
        send_json_message(conn, :ok, "Bid cancelled succesfully!")

      {:error, reason} ->
        send_json_error(conn, :bad_request, reason)
    end
  end

  defp handle_response(result, :new_offer_endpoint, conn) do
    case result do
      {:ok, bid} ->
        send_json_resp(conn, :created, encode_bid(bid))

      {:error, reason} ->
        send_json_error(conn, :bad_request, "Invalid bid: #{reason}")
    end
  end

  # TODO: mandar a un modulo aparte
  def send_json_message(conn, status, message) do
    conn
    |> send_json_resp_by(status, %{
      message: message
    })
  end

  def send_json_error(conn, status, error) do
    conn
    |> send_json_resp_by(status, %{
      error: error
    })
  end

  def send_json_resp(conn, :ok, response) do
    conn
    |> send_json_resp_by(200, response)
  end

  def send_json_resp(conn, :created, response) do
    conn
    |> send_json_resp_by(201, response)
  end

  def send_json_resp(conn, :bad_request, response) do
    conn
    |> send_json_resp_by(400, response)
  end

  def send_json_resp(conn, :not_found, response) do
    conn
    |> send_json_resp_by(404, response)
  end

  def send_json_resp(conn, :unprocessable_entity, response) do
    conn
    |> send_json_resp_by(422, response)
  end

  def send_json_resp(conn, :internal_server_error, response) do
    conn
    |> send_json_resp_by(500, response)
  end

  def send_json_resp_by(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(body))
  end

  defp encode_bid(bid) do
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
end

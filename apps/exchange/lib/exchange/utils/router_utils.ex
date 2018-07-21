defmodule Exchange.Utils.Router do
  @moduledoc """
  Funciones utilitarias para usar en el Router.
  """
  import Plug.Conn

  def handle_response(result, :buyers_endpoint, conn) do
    case result do
      {:ok, count} ->
        send_json_message(conn, :created, "Buyer added succesfully! Buyers: #{count}")

      {:error, :invalid_name} ->
        send_json_error(conn, :bad_request, "The name is already in use")

      {:error, :invalid_ip} ->
        send_json_error(conn, :bad_request, "Invalid IP")

      {:error, :invalid_tags} ->
        send_json_error(conn, :bad_request, "Invalid tags")

      {:error, reason} ->
        send_json_error(conn, :bad_request, reason)
    end
  end

  def handle_response(result, :bids_endpoint, conn) do
    case result do
      {:ok, bid} ->
        send_json_resp(conn, :created, encode_bid(bid))

      {:error, :invalid_close_at} ->
        send_json_error(conn, :bad_request, "Invalid close at")

      {:error, :invalid_json} ->
        send_json_error(conn, :bad_request, "Invalid request")

      {:error, :invalid_tags} ->
        send_json_error(conn, :bad_request, "Invalid tags")

      {:error, reason} ->
        send_json_error(conn, :bad_request, reason)
    end
  end

  def handle_response(result, :cancel_offer_endpoint, conn) do
    case result do
      {:ok} ->
        send_json_message(conn, :ok, "Bid cancelled succesfully!")

      {:error, reason} ->
        send_json_error(conn, :bad_request, reason)
    end
  end

  def handle_response(result, :new_offer_endpoint, conn) do
    case result do
      {:ok, bid} ->
        send_json_resp(conn, :created, encode_bid(bid))

      {:error, reason} ->
        send_json_error(conn, :bad_request, "Invalid bid: #{reason}")
    end
  end

  def send_json_message(conn, status, msg), do: send_json_resp_by(conn, status, %{message: msg})

  def send_json_error(conn, status, error), do: send_json_resp_by(conn, status, %{error: error})

  def send_json_resp(conn, :ok, response), do: send_json_resp_by(conn, 200, response)

  def send_json_resp(conn, :created, resp), do: send_json_resp_by(conn, 201, resp)

  def send_json_resp(conn, :bad_request, resp), do: send_json_resp_by(conn, 400, resp)

  def send_json_resp(conn, :not_found, resp), do: send_json_resp_by(conn, 404, resp)

  def send_json_resp(conn, :unprocessable_entity, resp), do: send_json_resp_by(conn, 422, resp)

  def send_json_resp(conn, :internal_server_error, resp), do: send_json_resp_by(conn, 500, resp)

  def send_json_resp_by(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(body))
  end

  def encode_bid(bid) do
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

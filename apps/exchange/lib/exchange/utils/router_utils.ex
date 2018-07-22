defmodule Exchange.Utils.Router do
  @moduledoc """
  Funciones utilitarias para usar en el Router.
  """
  import Plug.Conn

  @doc """
  Dada una respuesta, un endpoint y una conexion, envia la respuesta adecuada.
  """
  def handle_response({:ok, count}, :buyers_endpoint, conn),
    do: send_json_message(conn, :created, "Buyer added succesfully! Buyers: #{count}")

  def handle_response({:error, :invalid_name}, :buyers_endpoint, conn),
    do: send_json_error(conn, :bad_request, "The name is already in use")

  def handle_response({:error, :invalid_ip}, :buyers_endpoint, conn),
    do: send_json_error(conn, :bad_request, "Invalid IP")

  def handle_response({:error, :invalid_tags}, :buyers_endpoint, conn),
    do: send_json_error(conn, :bad_request, "Invalid tags")

  def handle_response({:error, reason}, :buyers_endpoint, conn),
    do: send_json_error(conn, :bad_request, reason)

  def handle_response({:ok, bid}, :bids_endpoint, conn),
    do: send_json_resp(conn, :created, encode_bid(bid))

  def handle_response({:error, :invalid_close_at}, :bids_endpoint, conn),
    do: send_json_error(conn, :bad_request, "Invalid close at")

  def handle_response({:error, :invalid_json}, :bids_endpoint, conn),
    do: send_json_error(conn, :bad_request, "Invalid request")

  def handle_response({:error, :invalid_tags}, :bids_endpoint, conn),
    do: send_json_error(conn, :bad_request, "Invalid tags")

  def handle_response({:error, reason}, :bids_endpoint, conn),
    do: send_json_error(conn, :bad_request, reason)

  def handle_response(:ok, :cancel_offer_endpoint, conn),
    do: send_json_message(conn, :ok, "Bid cancelled succesfully!")

  def handle_response({:error, reason}, :cancel_offer_endpoint, conn),
    do: send_json_error(conn, :bad_request, reason)

  def handle_response({:ok, bid}, :new_offer_endpoint, conn),
    do: send_json_resp(conn, :created, encode_bid(bid))

  def handle_response({:error, reason}, :new_offer_endpoint, conn),
    do: send_json_error(conn, :bad_request, "Invalid bid: #{reason}")

  def send_json_message(conn, status, msg), do: send_json_resp_by(conn, status, %{message: msg})

  def send_json_error(conn, status, error), do: send_json_resp_by(conn, status, %{error: error})

  def send_json_resp(conn, :ok, resp), do: send_json_resp_by(conn, 200, resp)
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

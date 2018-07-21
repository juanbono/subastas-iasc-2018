defmodule Exchange.Router do
  use Plug.Router
  import Exchange.Utils.Router

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  post "/buyers" do
    conn.body_params
    |> Exchange.create_buyer()
    |> handle_response(:buyers_endpoint, conn)
  end

  post "/bids" do
    conn.body_params
    |> Exchange.create_bid()
    |> handle_response(:bids_endpoint, conn)
  end

  post "/bids/offer" do
    conn.body_params
    |> Exchange.update_bid()
    |> handle_response(:new_offer_endpoint, conn)
  end

  post "/bids/cancel" do
    conn.body_params
    |> Exchange.cancel_bid()
    |> handle_response(:cancel_offer_endpoint, conn)
  end

  match _ do
    send_json_resp(conn, :not_found, "Valid endpoints: '/buyers' and '/bids'")
  end
end

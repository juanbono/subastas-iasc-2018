defmodule Client.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  post "/bids/open" do
    # Task.async(fn -> Client.OfferLogic.process(conn.body_params) end)
    Client.handle_open(conn.body_params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{message: "Ok"}))
  end

  post "/bids/new_offer" do
    # Task.async(fn -> Client.OfferLogic.process(conn.body_params) end)
    Client.handle_offer(conn.body_params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{message: "Ok, new bid received!\n"}))
  end

  post "/bids/close" do
    # IO.inspect(conn.body_params, label: "bid finalizada, se recibio")
    Client.handle_close(conn.body_params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{message: "Ok, bid finalization received!\n"}))
  end

  match _ do
    send_resp(conn, 404, Poison.encode!(%{error: "Wrong endpoint"}))
  end
end

defmodule Client.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  # {
  #   id: 1,
  #   offer: {
  #      description: "Unas buenas bucaneras",
  #      stock: 1,
  #      weight: 700,
  #      image_url: "https://grimoldimediamanager.grimoldi.com/MediaFiles/Grimoldi/2017/5_5/0/26/42/1714893.jpg"
  #   },
  #   close_for: 1529856667
  #   tags: ["moda", "zapatos"],
  #   seller: {
  #     id: 1,
  #     company_name: "Grimoldi"
  #   },
  #   price: 100
  # }
  post "/bids/open" do
    Task.async(
      fn -> Client.OfferLogic.process(conn.body_params) end
    )

    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Poison.encode!(%{response: "ok"}))
  end

  post "/bids/offer" do
    Task.async(
      fn -> Client.OfferLogic.process(conn.body_params) end
    )

    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Poison.encode!(%{response: "ok"}))
  end

  post "/bids/close" do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Poison.encode!(%{response: "ok"}))
  end

  match _ do
    send_resp(conn, 404, "Wrong endpoint.\n")
  end
end

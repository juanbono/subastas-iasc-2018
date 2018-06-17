defmodule Client.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  post "/notify" do
    send_resp(conn, 200, "event received \n")
  end

  match _ do
    send_resp(conn, 404, "Wrong endpoint.\n")
  end
end

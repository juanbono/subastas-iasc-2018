defmodule Client.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Client.Router.init([])

  test "Notify open bid succesfully" do
    body = Poison.encode!(%{
      id: 1,
      bid: %{
        description: "Jean Slim Tiana Azul",
        colour: "blue",
        stock: 1,
        image_url: "https://tascani.vteximg.com.br/arquivos/ids/161468-340-510/jean-slim-tiana-2.jpg"
      },
      best_offer: nil,
      close_for: 1529856667,
      tags: ["fashion", "jeans", "free_shipment"],
      seller: %{
        id: 1,
        company_name: "Tascani"
      },
      price: 2500
    })

    conn =
      conn(:post, "/bids/open", body)
      |> put_req_header("content-type", "application/json")

    conn = Client.Router.call(conn, @opts)
    response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
    assert response["message"] == "Ok"
  end

  test "Notify new offer succesfully" do
    body = Poison.encode!(%{
      id: 1,
      bid: %{
        description: "Jean Slim Tiana Azul",
        colour: "blue",
        stock: 1,
        image_url: "https://tascani.vteximg.com.br/arquivos/ids/161468-340-510/jean-slim-tiana-2.jpg"
      },
      best_offer: %{
        price: 2500,
        user_id: 40
      },
      close_for: 1529856667,
      tags: ["fashion", "jeans", "free_shipment"],
      seller: %{
        id: 1,
        company_name: "Tascani"
      },
      price: 2500
    })

    conn =
      conn(:post, "/bids/update", body)
      |> put_req_header("content-type", "application/json")

    conn = Client.Router.call(conn, @opts)
    response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
    assert response["message"] == "Ok"
  end

  test "Notify close bid succesfully" do
    body = Poison.encode!(%{
      id: 1,
      bid: %{
        description: "Jean Slim Tiana Azul",
        colour: "blue",
        stock: 1,
        image_url: "https://tascani.vteximg.com.br/arquivos/ids/161468-340-510/jean-slim-tiana-2.jpg"
      },
      best_offer: %{
        price: 2500,
        user_id: 40
      },
      close_for: 1529856667,
      tags: ["fashion", "jeans", "free_shipment"],
      seller: %{
        id: 1,
        company_name: "Tascani"
      },
      price: 2500
    })

    conn =
      conn(:post, "/bids/close", body)
      |> put_req_header("content-type", "application/json")

    conn = Client.Router.call(conn, @opts)
    response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
    assert response["message"] == "Ok"
  end
end

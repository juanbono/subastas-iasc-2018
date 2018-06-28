defmodule Exchange.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Exchange.Router.init([])

  test "Create buyer succesfully" do
    body = Poison.encode!(%{
      name: "buyer1",
      ip: "192.168.1.1",
      tags: ["cats"]
    })

    conn =
      conn(:post, "/buyers", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)
    response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 201
    assert response["message"] == "Buyer added succesfully! Buyers: 1"
  end

  test "Create buyers fails if ip is incomplete" do
    body = Poison.encode!(%{
      name: "buyer1",
      tags: ["cats"]
    })

    conn =
      conn(:post, "/buyers", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)
    response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 400
    assert response["error"] == "Invalid request"
  end

  test "Create buyer fail if name is incomplete" do
    body = Poison.encode!(%{
      ip: "192.168.1.1",
      tags: ["cats"]
    })

    conn =
      conn(:post, "/buyers", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)
    response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 400
    assert response["error"] == "Invalid request"
  end

  test "Create bid succesfully" do
    body = Poison.encode!(%{
      tags: ["cats"],
      price: 2.5,
      duration: 1000,
      json: %{
        name: "object1"
      }
    })

    conn =
      conn(:post, "/bids", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)
    response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 201
    assert response["message"] == "Bid added succesfully! Bids: 1"
  end

  test "Create bid fails if json is incomplete" do
    body = Poison.encode!(%{
      tags: ["cats"],
      price: 2.5,
      duration: 1000
    })

    conn =
      conn(:post, "/bids", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)
    response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 400
    assert response["error"] == "Invalid request"
  end

  test "Create bid fails if tags is incomplete" do
    body = Poison.encode!(%{
      price: 2.5,
      duration: 1000,
      json: %{
        name: "object1"
      }
    })

    conn =
      conn(:post, "/bids", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)
    response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 400
    assert response["error"] == "Invalid request"
  end

  test "Create bid fails if duration is incomplete" do
    body = Poison.encode!(%{
      tags: ["cats"],
      price: 2.5,
      json: %{
        name: "object1"
      }
    })

    conn =
      conn(:post, "/bids", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)
    response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 400
    assert response["error"] == "Invalid request"
  end
end

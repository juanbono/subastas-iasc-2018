defmodule Exchange.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Exchange.Router.init([])

  test "/buyers registers correctly" do
    body = Poison.encode!(%{name: "buyer1", ip: "192.168.1.1", tags: ["cats"]})

    conn =
      conn(:post, "/buyers", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Registration Completed! \n"
  end

  test "/buyers fails to register when the information is incomplete" do
    body = Poison.encode!(%{name: "buyer1", tags: ["cats"]})

    conn =
      conn(:post, "/buyers", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 400
    assert conn.resp_body == "Invalid request. \n"
  end

  test "/bids creates the bid succesfully" do
    body = Poison.encode!(%{tags: ["cats"], price: 2.5, duration: 1000, json: %{name: "object1"}})

    conn =
      conn(:post, "/bids", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Bid added succesfully!\n"
  end

  test "/bids fails when there is no json article" do
    body = Poison.encode!(%{tags: ["cats"], price: 2.5, duration: 1000})

    conn =
      conn(:post, "/bids", body)
      |> put_req_header("content-type", "application/json")

    conn = Exchange.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 400
    assert conn.resp_body == "Invalid bid. \n"
  end
end

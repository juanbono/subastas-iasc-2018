defmodule BuyersTest do
  use ExUnit.Case
  doctest Buyers

  test "greets the world" do
    assert Buyers.hello() == :world
  end
end

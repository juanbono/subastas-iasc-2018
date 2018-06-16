defmodule ExchangeTest do
  use ExUnit.Case
  doctest Exchange

  test "greets the world" do
    assert Exchange.hello() == :world
  end
end

defmodule Exchange.Buyers.Worker do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(_args) do
    {:ok, %{}}
  end
end

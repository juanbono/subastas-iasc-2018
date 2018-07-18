defmodule Bids.Supervisor do
  use DynamicSupervisor

  def init(_args) do
    DynamicSupervisor.init([])
  end

  def register(worker_name) do
    {:ok, _pid} = DynamicSupervisor.start_child(__MODULE__, [worker_name])
  end
end

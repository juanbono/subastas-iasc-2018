defmodule Exchange.Buyers.Supervisor do
  use DynamicSupervisor

  def init(_args) do
    DynamicSupervisor.init([])
  end
end

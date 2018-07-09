use Mix.Config

defmodule VarReader do
  def read_port(var) do
    case System.get_env(var) do
      nil ->
        nil

      port_number ->
        String.to_integer(port_number)
    end
  end
end

config :client, port: VarReader.read_port("PORT") || 5000

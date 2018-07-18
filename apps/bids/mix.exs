defmodule Bids.MixProject do
  use Mix.Project

  def project do
    [
      app: :bids,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :httpoison, :confex],
      mod: {Bids.Application, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.4.0"},
      {:plug, "~> 1.5.1"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.2.0"},
      {:amnesia, "~> 0.2.7"},
      {:libcluster, "~> 3.0.2"},
      {:swarm, "~> 3.3.1"},
      {:elixir_uuid, "~> 1.2"},
      {:unsplit, git: "https://github.com/discordapp/unsplit"},
      {:confex, "~> 3.3.1"}
    ]
  end
end

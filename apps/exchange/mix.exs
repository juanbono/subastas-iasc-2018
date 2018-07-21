defmodule Exchange.MixProject do
  use Mix.Project

  @version System.get_env("APP_VERSION") || "0.0.0"

  def project do
    [
      app: :exchange,
      version: @version,
      build_path: "./_build",
      config_path: "./config/config.exs",
      deps_path: "./deps",
      lockfile: "./mix.lock",
      elixir: "~> 1.6.6",
      # :prod
      start_permanent: Mix.env() == :docker,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :httpoison, :confex, :parse_trans],
      mod: {Exchange.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.4.0"},
      {:plug, "~> 1.5.1"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.2.0"},
      {:amnesia, "~> 0.2.7"},
      {:libcluster, "~> 3.0.2"},
      {:swarm, "~> 3.3.1"},
      {:credo, "~> 0.9.3", only: [:dev, :test], runtime: false},
      {:elixir_uuid, "~> 1.2"},
      {:confex, "~> 3.3.1"},
      {:distillery, "~> 1.5.3", runtime: false}
    ]
  end
end

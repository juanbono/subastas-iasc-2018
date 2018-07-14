defmodule Exchange.MixProject do
  use Mix.Project

  def project do
    [
      app: :exchange,
      version: "0.1.0",
      build_path: "./_build",
      config_path: "./config/config.exs",
      deps_path: "./deps",
      lockfile: "./mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :httpoison, :confex],
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
      {:elixir_uuid, "~> 1.2"},
      {:unsplit, git: "https://github.com/discordapp/unsplit"},
      {:confex, "~> 3.3.1"}
    ]
  end
end

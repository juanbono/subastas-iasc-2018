defmodule Subastas.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:cowboy, "~> 2.4.0"},
      {:plug, "~> 1.5.1"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.2.0"},
      {:amnesia, "~> 0.2.7"},
      {:elixir_uuid, "~> 1.2"},
      {:unsplit, git: "https://github.com/discordapp/unsplit"}
    ]
  end
end

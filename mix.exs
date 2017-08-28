defmodule Nb.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nb,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpotion, :timex],
      mod: {Nb.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, "~> 1.6.0"},
      {:httpotion, "~> 3.0.2"},
      {:poison, "~> 3.1"},
      {:timex, "~> 3.0"},
      {:ex_doc, "~> 0.16", only: :dev},
      {:plug, "~> 1.0"}
    ]
  end
end

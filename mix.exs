defmodule Elir.Mixfile do
  use Mix.Project

  @version "0.3.15"
  
  def project do
    [
      app: :elir,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      escript: [main_module: Elir],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :poolboy, :yaml_elixir]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_test_watch, "~> 0.4.0", runtime: false},
      {:secure_random, "~> 0.5"},
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:poolboy, "~> 1.5"},
      {:yaml_elixir, "~> 1.3"},
      {:inflectorex, "~> 0.1"},
    ]
  end
end

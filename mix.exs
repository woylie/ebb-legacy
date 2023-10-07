defmodule Ebb.MixProject do
  use Mix.Project

  def project do
    [
      app: :ebb,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def escript do
    [main_module: Ebb.CLI]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:tzdata, "~> 1.1"},
      {:yaml_elixir, "~> 2.9"}
    ]
  end

  defp aliases do
    [
      setup: [
        "deps.get",
        "cmd cp -r ./deps/tzdata/priv/release_ets ./.tzdata"
      ],
      build: ["setup", "escript.build"],
      install: ["build", "escript.install ebb"]
    ]
  end
end

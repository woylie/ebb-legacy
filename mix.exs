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
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls.github": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      dialyzer: [
        plt_file: {:no_warn, ".plts/dialyzer.plt"}
      ]
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
      {:credo, "== 1.7.12", only: [:dev, :test], runtime: false},
      {:dialyxir, "== 1.4.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "== 0.18.5", only: :test},
      {:jason, "== 1.4.4"},
      {:mix_audit, "== 2.1.4", only: [:dev, :test], runtime: false},
      {:tzdata, "== 1.1.3"},
      {:yaml_elixir, "== 2.11.0"}
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

defmodule BrokerMixProject do
  use Mix.Project

  def project do
    [
      app: :broker,
      name: "Broker",
      version: "1.0.0",
      elixir: "~> 1.5",
      deps: [
        {:poison, "~> 3.1"},
      ],
    ]
  end

  def application do
    [
      mod: {BrokerModule, []}
    ]
  end
end

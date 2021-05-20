defmodule ClientMixProject do
  use Mix.Project

  def project do
    [
      app: :client,
      name: "Client",
      version: "1.0.0",
      elixir: "~> 1.5",
      deps: [
        {:mongodb, "~> 0.5.1"},
        {:poison, "~> 3.1"},
      ],
    ]
  end

  def application do
    [
      mod: {ClientModule, []}
    ]
  end
end

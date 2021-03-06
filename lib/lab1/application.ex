defmodule Lab1.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Lab1.Worker.start_link(arg)
      # {Lab1.Worker, arg}
      #      {Lab1.Producer, :test},
      Lab1.Orchestrator
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lab1.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

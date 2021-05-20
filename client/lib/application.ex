defmodule ClientModule do
  use Application

  @impl true
  def start(_type, _args) do
    IO.puts("Starting Client")

    children = [
      %{
        id: Connector,
        start: {Connector, :connect, ['rtp-broker', 4040]},
      },
      %{
        id: Assistant,
        start: {Assistant, :start, [10, 5]},
      }
    ]
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end

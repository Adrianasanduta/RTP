defmodule ServerModule do
  use Application

  @impl true
  def start(_type, _args) do
    IO.puts("Starting Server")

    children = [
      %{
        id: Queue,
        start: {Queue, :start_link, []}
      },
      %{
        id: QHandler,
        start: {QHandler, :start_link, []}
      },
      %{
        id: Connector,
        start: {Connector, :connect, ['rtp-broker', 4040]}
      },
      %{
        id: FirstSource,
        start: {Fetch, :init, ["rtp-api:4000/tweets/1"]}
      },
      %{
        id: SecondSource,
        start: {Fetch, :init, ["rtp-api:4000/tweets/2"]}
      }
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end

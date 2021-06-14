defmodule Lab1.Producer do
  use GenServer

  alias EventsourceEx.Message

  def start_link(%{parent_pid: parent_pid, endpoint: endpoint}) do
    GenServer.start_link(__MODULE__, parent_pid: parent_pid, endpoint: endpoint)
  end

  def init(opts) do
    parent_pid = Keyword.fetch!(opts, :parent_pid)
    endpoint = Keyword.fetch!(opts, :endpoint)

    # This library doesn't handle failure of connection, producer will not work if the endpoint is not streaming data
    EventsourceEx.new(endpoint, stream_to: self())
    {:ok, parent_pid}
  end

  # Take the incoming messages and send them to orchestrator
  def handle_info(%Message{} = message, parent_pid) do
    send(parent_pid, message)
    {:noreply, parent_pid}
  end
end

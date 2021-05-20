defmodule Connector do
  use GenServer

  def init(arg) do
    {:ok, arg}
  end

  def connect(host, port) do
    {:ok, socket} = TCPGen.connect(host, port)
    IO.puts("Server is connected to broker #{host}:#{port}")

    GenServer.start_link(__MODULE__, %{socket: socket}, name: __MODULE__)
  end

  def send_topic(topic, content) do
    GenServer.cast(
      __MODULE__,
      {:send_topic, Poison.encode!(%{type: "content", topic: topic, content: content})}
    )
  end

  def handle_cast({:send_topic, data}, state) do
    TCPGen.send(state.socket, data)

    {:noreply, state}
  end
end

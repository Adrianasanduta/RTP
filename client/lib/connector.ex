defmodule Connector do
  use GenServer

  def init(arg) do
    {:ok, arg}
  end

  def connect(host, port) do
    {:ok, socket} = TCPGen.connect(host, port)
    IO.puts("Client is connected to broker #{host}:#{port}")

    GenServer.start_link(__MODULE__, %{socket: socket}, name: __MODULE__)
  end

  def read() do
    GenServer.cast(__MODULE__, {:read})
  end

  def subscribe(topic) do
    GenServer.cast(__MODULE__, {:subscribe, Poison.encode!(%{type: "subscribe", topic: topic})})
  end

  def unsubscribe(topic) do
    GenServer.cast(__MODULE__, {:subscribe, Poison.encode!(%{type: "unsubscribe", topic: topic})})
  end

  def handle_cast({:subscribe, data}, state) do
    TCPGen.send(state.socket, data)

    {:noreply, state}
  end

  def handle_cast({:read}, state) do
    response = TCPGen.read(state.socket)
    Assistant.handle_response(response)
    {:noreply, state}
  end
end

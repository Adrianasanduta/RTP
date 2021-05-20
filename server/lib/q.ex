defmodule Queue do
  use GenServer

  def init(arg) do
    {:ok, arg}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{queue: :queue.new()}, name: __MODULE__)
  end

  def add(topic, content) do
    GenServer.cast(__MODULE__, {:add, topic, content})
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def length() do
    GenServer.call(__MODULE__, :length)
  end

  def handle_cast({:add, topic, content}, state) do
    queue = :queue.in(%{topic: topic, content: content}, state.queue)
    {:noreply, %{queue: queue}}
  end

  def handle_call(:get, _, state) do
    {head, queue} = :queue.out(state.queue)

    if head == :empty do
      {:reply, nil, %{queue: queue}}
    else
      {:value, first} = head;
      {:reply, first, %{queue: queue}}
    end
  end

  def handle_call(:length, _, state) do
    {:reply, :queue.len(state.queue), state}
  end
end

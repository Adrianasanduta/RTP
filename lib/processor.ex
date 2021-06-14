defmodule Lab1.Processor do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_opts) do
    IO.inspect("started worker #{inspect(self())}")
    {:ok, []}
  end

  def handle_info({:handle_work, message, parent_pid}, _state) do
    # Random wait time from 50ms to 1000ms
    work_time = rem(:rand.uniform(1000) + 50, 500)

    # Decode the json received from producer
    case Jason.decode(message.data) do
      {:ok, decoded} -> send(parent_pid, {:work_success, decoded, self()})
      {:error, reason} -> send(parent_pid, {:work_error, message, reason, self()})
    end

    # Dummy load
    Process.sleep(work_time)

    {:noreply, []}
  end
end

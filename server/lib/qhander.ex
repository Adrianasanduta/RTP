defmodule Queue.Manager do
  use GenServer

  def init(arg) do
    manage()
    {:ok, arg}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def handle_info(:manage, state) do
    if Queue.length() > 0 do
      response = Queue.get()
      Connector.send_topic(response.topic, response.content)
      manage()
    else
      manage()
    end
    {:noreply, state}
  end

  defp manage() do
    Process.send_after(self(), :manage, 5000)
  end
end
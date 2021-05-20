defmodule QHandler do
  use GenServer

  def init(arg) do
    manage()
    {:ok, arg}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def handle_info(:manage, state) do
    IO.puts("check queue")

    if Queue.length() > 0 do
      {client, content} = Queue.get()
      Handler.send_content(client, content)
      manage()
    else
      manage()
    end

    {:noreply, state}
  end

  defp manage() do
    Process.send_after(self(), :manage, 1000)
  end
end

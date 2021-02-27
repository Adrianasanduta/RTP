defmodule Connection do

  def start_link(url) do
    {:ok, _pid} = EventsourceEx.new(url, stream_to: self())
    getMessage()
  end

  def getMessage() do
    receive do
      message -> messageBehaviour(message)
    end
  end

  def messageBehaviour(message) do
    GenServer.cast(Router, {:router, message})
    getMessage()
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

end

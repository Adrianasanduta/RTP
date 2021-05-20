defmodule Fetch do
  def init(url) do
    EventsourceEx.new(url, stream_to: self())
    loop_fetch()
  end

  def loop_fetch() do
    receive do
      res ->
        Dispatch.dispatch(res.data)
        loop_fetch()
    end
  end
end

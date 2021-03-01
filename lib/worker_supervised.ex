defmodule Worker do
  use GenServer

  def init(message) do
    {:ok, %{name: message}}
  end

  def start_link(message) do
    GenServer.start_link(
      __MODULE__,
      message,
      name: __MODULE__
      )
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def handle_call(:get, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_cast({:worker, message}, _smth) do
    process_data(message)
    {:noreply, %{}}
  end

  def read_json(message) do
    decoded_message = Poison.decode!(message.data)
    decoded_message["message"]["tweet"]["text"]
  end

  defp make_analysis(values) do
    values
    |> Enum.reduce(0, fn key_value, coll -> EmotionScores.get_emotion(key_value) + coll end)
    |> Kernel./(length(values))
  end

  def process_data(message) do
    if message.data =~ "panic" do
      IO.inspect("KILL MESSAGE HERE")
    else
      rm_characters = [",", ":", "?", ".", "!"]
      text = read_json(message)
      |> String.replace(rm_characters, "")

      score = make_analysis(text |> String.split(" ", trim: true))
      log("#{score} ==> #{text}")
    end
  end

  def log(data) do
    data |> inspect() |> IO.puts()
    data
  end
end

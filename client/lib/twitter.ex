defmodule Twitter do
  use GenServer

  def init(arg) do
    {:ok, arg}
  end

  def start(name, database, collection, bulkSize, bulkDebounce) do
    database = Database.connect(name, database, collection, bulkSize, bulkDebounce)
    IO.puts("Twitter Service was Initialized")

    GenServer.start_link(__MODULE__, %{database: database}, name: __MODULE__)
  end

  def get_score(text) do
    scoreDict = EmotionScores.getScoreDict()

    words =
      text
      |> String.replace(["!", "?", ":", ",", "."], "")
      |> String.split(" ", trim: true)

    words
    |> Enum.reduce(
      0,
      fn
        word, acc -> Map.get(scoreDict, String.to_atom(word), 0) + acc
      end
    )
    |> Kernel./(length(words))
  end

  @impl true
  def handle_cast({:save, tweet}, state) do
    new_tweet = %{
      id: tweet["id"],
      created_at: tweet["created_at"],
      created_by: tweet["user"],
      score: get_score(tweet["text"]),
      text: tweet["text"]
    }

    state.database
    |> Tuple.to_list()
    |> Enum.at(1)
    |> GenServer.cast({:save, new_tweet})

    {:noreply, state}
  end
end

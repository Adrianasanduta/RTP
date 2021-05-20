defmodule Users do
  use GenServer

  def init(arg) do
    {:ok, arg}
  end

  def start(name, database, collection, bulkSize, bulkDebounce) do
    database = Database.connect(name, database, collection, bulkSize, bulkDebounce)
    IO.puts("Users Service was Initialized")

    GenServer.start_link(__MODULE__, %{database: database}, name: __MODULE__)
  end

  @impl true
  def handle_cast({:save, user}, state) do
    state.database
    |> Tuple.to_list()
    |> Enum.at(1)
    |> GenServer.cast({:save, user})

    {:noreply, state}
  end
end

defmodule Database do
  use GenServer

  def init(arg) do
    {:ok, arg}
  end

  def connect(name, database, collection, bulkSize, bulkDebounce) do
    {:ok, connection} = Mongo.start_link(url: "mongodb://rtp-database:27017", database: database)
    IO.puts(
      "Connected to database #{database}/#{collection} with bulkSize #{bulkSize} and debounce #{bulkDebounce}ms"
    )

    GenServer.start_link(
      __MODULE__,
      %{
        connection: connection,
        collection: collection,
        bulkSize: bulkSize,
        bulkDebounce: bulkDebounce,
        bulkTime: :os.system_time(:millisecond),
        data: [],
      },
      name: String.to_atom(name)
    )
  end

  @impl true
  def handle_cast({:save, data}, state) do
    passedTime = :os.system_time(:millisecond) - state.bulkTime
    isSameLength = length(state.data) == state.bulkSize
    isPassedTime = passedTime > state.bulkDebounce
    hasData = length(state.data) > 0

    if ((isSameLength || isPassedTime) && hasData) do
      IO.puts("Saved #{length(state.data)} #{state.collection} in database with the time #{passedTime}ms")
      Mongo.insert_many(state.connection, state.collection, state.data)
      {
        :noreply,
        %{
          connection: state.connection,
          collection: state.collection,
          bulkSize: state.bulkSize,
          bulkDebounce: state.bulkDebounce,
          bulkTime: :os.system_time(:millisecond),
          data: [],
        }
      }
    else
      {
        :noreply,
        %{
          connection: state.connection,
          collection: state.collection,
          bulkSize: state.bulkSize,
          bulkDebounce: state.bulkDebounce,
          bulkTime: state.bulkTime,
          data: [data | state.data],
        }
      }
    end
  end
end
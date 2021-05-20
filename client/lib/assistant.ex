defmodule Assistant do
  use GenServer

  def init(arg) do
    {:ok, arg}
  end

  def start(tweetsLimit, usersLimit) do
    twitterService = Twitter.start("Twitter", "RTP", "tweets", 1, 200)
    usersService = Users.start("Users", "RTP", "users", 1, 1000)

    if tweetsLimit > 0 do
      Connector.subscribe("tweets")
      IO.puts("Client was subscribed to topic: tweets")
    end

    if usersLimit > 0 do
      Connector.subscribe("users")
      IO.puts("Client was subscribed to topic: users")
    end

    GenServer.start_link(
      __MODULE__,
      %{
        twitterService: twitterService,
        tweetsSaved: 0,
        tweetsLimit: 10,
        usersService: usersService,
        usersSaved: 0,
        usersLimit: 5
      },
      name: __MODULE__
    )

    loop_acceptor()
  end

  defp loop_acceptor() do
    Connector.read()
    loop_acceptor()
  end

  def handle_response(response) do
    decoded = Poison.decode!(response)
    GenServer.cast(__MODULE__, {:save, decoded})
  end

  def handle_cast({:save, data}, state) do
    topic = data["topic"]
    content = data["content"]
    tweetsSaved = state.tweetsSaved
    usersSaved = state.usersSaved

    if content do
      case topic do
        "tweets" ->
          if state.tweetsLimit > 0 do
            if tweetsSaved < state.tweetsLimit do
              IO.puts("Got the tweet from server")
              IO.inspect(content)

              state.twitterService
              |> Tuple.to_list()
              |> Enum.at(1)
              |> GenServer.cast({:save, content})

              tweetsSaved = state.tweetsSaved + 1
            else
              Connector.unsubscribe("tweets")
              IO.puts("Client was unsubscribed from topic: tweets")
            end
          end

        "users" ->
          if state.usersLimit > 0 do
            if usersSaved < state.usersLimit do
              IO.puts("Got the user from server")
              IO.inspect(content)

              state.usersService
              |> Tuple.to_list()
              |> Enum.at(1)
              |> GenServer.cast({:save, content})

              usersSaved = state.usersSaved + 1
            else
              Connector.unsubscribe("users")
              IO.puts("Client was unsubscribed from topic: users")
            end
          end
      end
    end

    {
      :noreply,
      %{
        twitterService: state.twitterService,
        tweetsSaved: tweetsSaved,
        tweetsLimit: state.tweetsLimit,
        usersService: state.usersService,
        usersSaved: usersSaved,
        usersLimit: state.usersLimit
      }
    }
  end
end

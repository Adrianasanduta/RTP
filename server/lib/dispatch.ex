defmodule Dispatch do
  def init(arg) do
    {:ok, arg}
  end

  def dispatch(data) do
    if data != "{\"message\": panic}" do
      decoded = Poison.decode!(data)
      tweet = decoded["message"]["tweet"]
      user = tweet["user"]

      new_tweet = %{
        user: user["id"],
        text: tweet["text"],
        created_at: tweet["created_at"]
      }

      new_user = %{
        id: user["id"],
        name: user["name"]
      }

      Queue.add("tweets", new_tweet)
      Queue.add("users", new_user)
    end
  end
end

defmodule Handler do
  defp handle_action(:subscribe, client, topic) do
    Registry.add(topic, client)
  end

  defp handle_action(:unsubscribe, client, topic) do
    Registry.delete(topic, client)
  end

  defp send_content(client, content) do
    try do
      TCPGen.send(client, content)
      IO.puts("Data was send to the client")
    rescue
      _ ->
        IO.puts("Could not send data to the client, adding to the queue")
        Queue.add(client, content)
    end
  end

  def handle(data, client) do
    decoded = Poison.decode!(data)
    topic = decoded["topic"]
    type = decoded["type"]

    IO.puts("Request type is: #{type}")

    clients = Registry.get(topic)

    if type == "content" do
      IO.puts("Send content to the following clients:")
      IO.inspect(clients)

      decoded_content = decoded["content"]
      encoded_data = Poison.encode!(%{topic: topic, content: decoded_content})

      for _client <- clients do
        send_content(_client, encoded_data)
      end
    else
      handle_action(String.to_atom(type), client, topic)
    end
  end
end

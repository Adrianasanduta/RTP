defmodule Broker do
  def accept(port) do
    {:ok, socket} = TCPGen.listen(port)
    IO.puts("Broker is listening on port #{port}")

    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = TCPGen.accept(socket)
    pid = spawn_link(__MODULE__, :read, [client])
    :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  def read(:error, client) do
    read(client)
  end

  def read(body, client) do
    decoded = Poison.decode!(body)
    IO.puts("Got the client body")
    IO.inspect(decoded)
    Handler.handle(body, client)
    read(client)
  end

  def read(client) do
    response = TCPGen.read(client)
    read(response, client)
  end
end

defmodule TCPGen do
  def listen(port) do
    :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true])
  end

  def accept(socket) do
    :gen_tcp.accept(socket)
  end

  def send(socket, data) do
    :gen_tcp.send(socket, data)
  end

  def read(client) do
    try do
      {:ok, body} = :gen_tcp.recv(client, 0)
      body
    rescue
      _ -> :error
    end
  end
end

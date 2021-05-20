defmodule TCPGen do
  def connect(host, port) do
    :gen_tcp.connect(host, port, [:binary, active: false])
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

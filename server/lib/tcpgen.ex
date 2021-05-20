defmodule TCPGen do
  def connect(host, port) do
    :gen_tcp.connect(host, port, [:binary, active: false])
  end

  def send(socket, data) do
    :gen_tcp.send(socket, data)
  end
end

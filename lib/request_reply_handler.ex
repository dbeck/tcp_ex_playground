defmodule RequestReply.Handler do

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end
         
  def init(ref, socket, transport, _Opts = []) do
    :ok = :ranch.accept_ack(ref)
    loop(socket, transport)
  end

  def loop(socket, transport) do
    case transport.recv(socket, 0, 5000) do
      {:ok, << id :: binary-size(8), sz :: size(32), data :: binary-size(sz) >> } ->
        transport.send(socket, id)
        loop(socket, transport)
      _ ->
        :ok = transport.close(socket)
    end
  end
end

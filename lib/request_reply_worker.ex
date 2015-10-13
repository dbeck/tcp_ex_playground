defmodule RequestReply.Worker do
  def start_link do
    opts = [port: 8001]
    {:ok, _} = :ranch.start_listener(:RequestReply, 10, :ranch_tcp, opts, RequestReply.Handler, [])
  end
end

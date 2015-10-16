defmodule ThrottleAck.Worker do
  def start_link do
    opts = [port: 8002]
    {:ok, _} = :ranch.start_listener(:ThrottleAck, 10, :ranch_tcp, opts, ThrottleAck.Handler, [])
  end
end
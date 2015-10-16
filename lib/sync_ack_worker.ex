defmodule SyncAck.Worker do
  def start_link do
    opts = [port: 8004]
    {:ok, _} = :ranch.start_listener(:SyncAck, 10, :ranch_tcp, opts, SyncAck.Handler, [])
  end
end

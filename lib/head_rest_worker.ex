defmodule HeadRest.Worker do
  def start_link do
    opts = [port: 8003]
    {:ok, _} = :ranch.start_listener(:HeadRest, 10, :ranch_tcp, opts, HeadRest.Handler, [])
  end
end

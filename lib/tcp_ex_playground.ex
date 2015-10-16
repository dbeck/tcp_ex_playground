defmodule TcpExPlayground do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(RequestReply.Worker, []),
      worker(ThrottleAck.Worker, []),
      worker(HeadRest.Worker, []),
      worker(SyncAck.Worker, [])
    ]

    opts = [strategy: :one_for_one, name: TcpExPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

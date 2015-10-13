defmodule RequestReply do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [ worker(RequestReply.Worker, []) ]
    opts = [strategy: :one_for_one, name: RequestReply.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

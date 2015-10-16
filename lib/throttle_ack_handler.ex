defmodule ThrottleAck.Handler do

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, _Opts = []) do
    :ok = :ranch.accept_ack(ref)
    {:ok, container} = ThrottleAck.Container.start_link
    timer_pid = spawn_link(__MODULE__, :timer, [socket, transport, container])
    loop(socket, transport, container, timer_pid)
  end
  
  def flush(socket, transport, container) do
    list = ThrottleAck.Container.flush(container)
    case ThrottleAck.Container.generate_ack(list) do  
      {id, skipped} ->
        packet = << id :: binary-size(8), skipped :: little-size(32) >>
        transport.send(socket, packet)
      {} ->
        IO.puts "empty data, everything flushed already"
    end
  end
  
  def timer(socket, transport, container) do
    flush(socket, transport, container)
    receive do
      {:stop} ->
        IO.puts "stop command arrived"
        :stop
    after
      5 ->
        timer(socket, transport, container)
    end
  end
  
  def shutdown(socket, transport, container, timer_pid) do
    ThrottleAck.Container.stop(container)
    :ok = transport.close(socket)
    send timer_pid, {:stop}
  end
  
  def loop(socket, transport, container, timer_pid) do
    case transport.recv(socket, 12, 5000) do
      {:ok, id_sz_bin} ->
        << id :: binary-size(8), sz :: little-size(32) >> = id_sz_bin
        case transport.recv(socket, sz, 5000) do
          {:ok, data} ->
            ThrottleAck.Container.push(container, id, data)
            loop(socket, transport, container, timer_pid)
          {:error, :timeout} ->
            flush(socket, transport, container)
            shutdown(socket, transport, container, timer_pid)
          _ ->
            shutdown(socket, transport, container, timer_pid)
        end
      _ ->
        shutdown(socket, transport, container, timer_pid)
    end
  end
end

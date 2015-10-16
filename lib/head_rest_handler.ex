defmodule HeadRest.Handler do

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, _Opts = []) do
    :ok = :ranch.accept_ack(ref)
    {:ok, container} = HeadRest.Container.start_link
    timer_pid = spawn_link(__MODULE__, :timer, [socket, transport, container])
    transport.setopts(socket, [nodelay: :true])
    loop(socket, transport, container, timer_pid, << >>)
  end
  
  def flush(socket, transport, container) do
    list = HeadRest.Container.flush(container)
    case HeadRest.Container.generate_ack(list) do  
      {id, skipped} ->
        packet = << id :: binary-size(8), skipped :: little-size(32) >>
        transport.send(socket, packet)
      {} ->
        :ok
    end
  end
  
  def timer(socket, transport, container) do
    flush(socket, transport, container)
    receive do
      {:stop} -> :stop
    after
      5 -> timer(socket, transport, container)
    end
  end
    
  def loop(socket, transport, container, timer_pid, yet_to_parse) do
    case transport.recv(socket, 0, 5000) do
      {:ok, packet} ->
        not_yet_parsed = process(container, yet_to_parse <> packet)
        loop(socket, transport, container, timer_pid, not_yet_parsed)
      {:error, :timeout} ->
        flush(socket, transport, container)
        shutdown(socket, transport, container, timer_pid)
      _ ->
        shutdown(socket, transport, container, timer_pid)
    end    
  end
  
  defp shutdown(socket, transport, container, timer_pid) do
    HeadRest.Container.stop(container)
    :ok = transport.close(socket)
    send timer_pid, {:stop}
  end
  
  defp process(_container, << >> ) do
    << >>
  end
  
  defp process(container, packet) do
    case packet do
      << id :: binary-size(8), sz :: little-size(32) , data :: binary-size(sz) >> ->
        HeadRest.Container.push(container, id, data)
        << >>
      << id :: binary-size(8), sz :: little-size(32) , data :: binary-size(sz) , rest :: binary >> ->
        HeadRest.Container.push(container, id, data)
        process(container, rest)
      unparsed ->
        unparsed
      end
  end
end
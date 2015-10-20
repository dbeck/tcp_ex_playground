defmodule AsyncAck.Handler do

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, _Opts = []) do
    :ok = :ranch.accept_ack(ref)
    transport.setopts(socket, [nodelay: :true])
    responder_pid = spawn_link(__MODULE__, :responder, [socket, transport, <<>>, [], 0])
    Process.flag(:trap_exit, true)
    loop(socket, transport, responder_pid)
  end
  
  def calc_skipped([]) do
    0
  end
  
  def calc_skipped([{_, skipped}]) do
    skipped
  end
  
  def calc_skipped([{_, skipped} | rest]) do
    1 + skipped + calc_skipped(rest)
  end

  def flush(_, _, []) do
  end
  
  def flush(socket, transport, ack_list) do
    [{id, _ } | _ ] = ack_list
    skipped = calc_skipped(ack_list)
    packet = << id :: binary-size(8), skipped :: little-size(32) >>
    transport.send(socket, packet)
  end
  
  def responder(socket, transport, yet_to_parse, ack_list, packet_count) do
    receive do
      {:message, packet} ->
        case parse(yet_to_parse <> packet, << >>, 0) do
          {not_yet_parsed, {id, skipped} } ->
            new_ack_list = [{id, skipped} | ack_list]
            if packet_count > 20 do
               flush(socket, transport, new_ack_list)
               responder(socket, transport, not_yet_parsed, [], 0)
            else
              responder(socket, transport, not_yet_parsed, new_ack_list, packet_count+1)
            end
          {not_yet_parsed, {} } ->
            responder(socket, transport, not_yet_parsed, ack_list, packet_count+1)
        end
      {:stop} -> :stop
    after
      5 ->
        flush(socket, transport, ack_list)
        responder(socket, transport, yet_to_parse, [], 0)        
    end
  end
      
  def loop(socket, transport, responder_pid) do
    case transport.recv(socket, 0, 5000) do
      {:ok, packet} ->
        send responder_pid, {:message, packet}
        loop(socket, transport, responder_pid)
      {:error, :timeout} ->
        shutdown(socket, transport, responder_pid)
      _ ->
        shutdown(socket, transport, responder_pid)
    end    
  end
  
  defp shutdown(socket, transport, responder_pid) do
    send responder_pid, {:stop}
    receive do
      {:EXIT, responder_pid, :normal} -> :ok
    end
    :ok = transport.close(socket)
  end

  defp parse(<< >>, << >>, _skipped ) do
    { << >>, {} }
  end
  
  defp parse(<< >>, last_id, skipped ) do
    { << >>, { last_id, skipped } }
  end

  defp parse(packet, << >>, 0) do
    case packet do
      # TODO : revise this 1MB safeguard against garbage here
      << id :: binary-size(8), sz :: little-size(32) , _data :: binary-size(sz) >> when sz < 1_000_000 ->
        { << >>, { id, 0 } }
      << id :: binary-size(8), sz :: little-size(32) , _data :: binary-size(sz) , rest :: binary >> when sz < 100 ->
        parse(rest, id, 0)
      unparsed ->
        { unparsed, {} }
    end
  end
  
  defp parse(packet, last_id, skipped) do
    case packet do
      # TODO : revise this 1MB safeguard against garbage here
      << id :: binary-size(8), sz :: little-size(32) , _data :: binary-size(sz) >> when sz < 1_000_000  ->
        { << >>, { id, skipped+1 } }
      << id :: binary-size(8), sz :: little-size(32) , _data :: binary-size(sz) , rest :: binary >> when sz < 100 ->
        parse(rest, id, skipped+1)
      unparsed ->
        { unparsed, {last_id, skipped} }
    end
  end
end
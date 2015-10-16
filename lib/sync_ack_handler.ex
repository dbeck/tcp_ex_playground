defmodule SyncAck.Handler do

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, _Opts = []) do
    :ok = :ranch.accept_ack(ref)
    transport.setopts(socket, [nodelay: :true])
    loop(socket, transport, << >>)
  end
      
  def loop(socket, transport, yet_to_parse) do
    case transport.recv(socket, 0, 5000) do
      {:ok, packet} ->
        case process(yet_to_parse <> packet, << >>, 0) do
          {not_yet_parsed, {id, skipped} } ->
            packet = << id :: binary-size(8), skipped :: little-size(32) >>
            transport.send(socket, packet)
            loop(socket, transport, not_yet_parsed)
          {not_yet_parsed, {} } ->
              loop(socket, transport, not_yet_parsed)
        end
      {:error, :timeout} ->
        shutdown(socket, transport)
      _ ->
        shutdown(socket, transport)
    end    
  end
  
  defp shutdown(socket, transport) do
    :ok = transport.close(socket)
  end

  defp process(<< >>, << >>, _skipped ) do
    { << >>, {} }
  end
  
  defp process(<< >>, last_id, skipped ) do
    { << >>, { last_id, skipped } }
  end

  defp process(packet, << >>, 0) do
    case packet do
      << id :: binary-size(8), sz :: little-size(32) , _data :: binary-size(sz) >> ->
        { << >>, { id, 0 } }
      << id :: binary-size(8), sz :: little-size(32) , _data :: binary-size(sz) , rest :: binary >> ->
        process(rest, id, 0)
      unparsed ->
        { unparsed, {} }
    end
  end
  
  defp process(packet, last_id, skipped) do
    case packet do
      << id :: binary-size(8), sz :: little-size(32) , _data :: binary-size(sz) >> ->
        { << >>, { id, skipped+1 } }
      << id :: binary-size(8), sz :: little-size(32) , _data :: binary-size(sz) , rest :: binary >> ->
        process(rest, id, skipped+1)
      unparsed ->
        { unparsed, {last_id, skipped} }
    end
  end
end
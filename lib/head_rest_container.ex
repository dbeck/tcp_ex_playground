defmodule HeadRest.Container do
  
  def start_link do
    Agent.start_link(fn -> [] end)
  end
  
  def stop(container) do
    Agent.stop(container)
  end
  
  def flush(container) do
    Agent.get_and_update(container, fn list -> {list, []} end)
  end
  
  def push(container, id, data) do
    Agent.update(container, fn list -> [{id, data}| list] end)
  end
  
  defp generate([]) do
    {}
  end
  
  defp generate( [{id, _}] ) do
    {id, 0}
  end
  
  defp generate( [{id, _} | tail] ) do
    tail_len = List.foldl(tail, 0, fn (_, acc) -> 1 + acc end)
    {id, tail_len}
  end
  
  def generate_ack(list) do
    generate(list)
  end
end
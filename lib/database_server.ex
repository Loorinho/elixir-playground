defmodule DatabaseServer do
  def start do
    spawn(&loop/0)
  end

  # Running the database server
  def run_async(server_pid, query) do
    send(server_pid, {:run_query, self(), query})
  end

  defp run_query(query_def) do
    Process.sleep(2000)
    IO.puts("#{query_def} result")
  end

  defp loop  do
    receive do
      {:run_query, caller, query_definition } ->
          query_result = run_query(query_definition)
          send(caller, {:results, query_result})
    end
    loop()
  end

  def get_result do
    receive do
      {:results, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end
end

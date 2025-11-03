defmodule ServerWithState do
  def start do
    spawn(fn ->
      # simulate creating a connection handler
      connection = :rand.uniform(1000)
      # passing the connection handler in the loop function which listens for requests
      loop(connection)
    end)
  end

  def run_async(server_pid, query) do
    send(server_pid, {:run_query, self(), query})
  end

  defp loop(connection) do
    receive do
      {:run_query, from_pid, query_definition} ->
        # adding the handler to the function which runs the query
        query_result = run_query(connection, query_definition)
        send(from_pid, {:results, query_result})
    end

    # maintaining the connection
    loop(connection)
  end

  defp run_query(connection, query_def) do
    Process.sleep(2000)

    # using the connection handler when running the query
    "#{query_def} result using connection #{connection}"
  end

  # to get the results
  def get_result do
    receive do
      {:results, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end
end

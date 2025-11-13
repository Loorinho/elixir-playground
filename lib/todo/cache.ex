defmodule Todo.Cache do
  use GenServer

  # WE wan't to be able to run multiple to-do lists at the same time,
  # So, i am creating this cache which will enable me run as many processes as there are todo-lists that way, i can run each list concurrently hence eliminating a scenario where there is only one TodoList server process handling multiple users [Who might end up bliocking each other]

  # Interface functions

  # Starts our cache process
  def start do
    GenServer.start(__MODULE__, nil)
  end

  # Get the todo-list's pid given mane
  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  # Server

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  # Call because we must return a result to the caller (a to-do server pid)
  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _from, state) do
    case Map.fetch(state, todo_list_name) do
      # If there is something for a given key, we return the value to the caller ofc leaving the state unchanged
      {:ok, todo_server} ->
        {:reply, todo_server, state}

      # Otherwise, we start a new process, return its pid and also insert an appropriate name-value pair in the process state
      :error ->
        # We start a new server
        {:ok, new_server} = Todo.Server.start()
        # And then add it to the map with that given key
        {:reply, new_server, Map.put(state, todo_list_name, new_server)}
    end
  end

  # Example
  # > {:ok, cache} = Todo.Cache.start()
  # > Todo.Cache.server_process(cache, "Loorinho's list")
  # > Todo.Cache.server_process(cache, "Loorinho's list") # This will return the same value as the line above it coz
end

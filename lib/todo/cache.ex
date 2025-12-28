defmodule Todo.Cache do
  use GenServer

  # WE wan't to be able to run multiple to-do lists at the same time,
  # So, i am creating this cache which will enable me run as many processes as there are todo-lists that way, i can run each list concurrently hence eliminating a scenario where there is only one TodoList server process handling multiple users [Who might end up bliocking each other]

  # Interface functions

  # Starts our cache process
  def start_link(_) do
    # start_link because we want it to be linked to the caller process
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # Get the todo-list's pid given mane
  # def server_process(cache_pid, todo_list_name) do
  def server_process(todo_list_name) do
    # we now use the registered name of the cache instead of always using its pid
    # GenServer.call(cache_pid, {:server_process, todo_list_name})
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  # Server

  @impl GenServer
  def init(_) do
    IO.puts("Starting to-do cache")

    # Starts the databse server
    # Todo.Database.start()
    # Initializes the Cache
    {:ok, %{}}
  end

  # Call because we must return a result to the caller (a to-do server pid)
  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _from, todo_list_servers) do
    case Map.fetch(todo_list_servers, todo_list_name) do
      # If there is something for a given key, we return the value to the caller ofc leaving the state unchanged
      {:ok, todo_server} ->
        {:reply, todo_server, todo_list_servers}

      # Otherwise, we start a new process, return its pid and also insert an appropriate name-value pair in the process state
      :error ->
        # We start a new server
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        # And then add it to the map with that given key
        {:reply, new_server, Map.put(todo_list_servers, todo_list_name, new_server)}
    end
  end

  # Example
  # > {:ok, cache} = Todo.Cache.start()
  # >loorinho_list = Todo.Cache.server_process(cache, "Loorinho's list")
  # > Todo.Cache.server_process(cache, "Loorinho's list") # This will return the same value as the line above it coz
  # > alice_list = Todo.Cache.server_process(cache, "Alice's list")
  # > Todo.Server.add_entry(loor_list,%Todo.List{title: "Going to church", date: ~D[2025-11-13]})
  # > Todo.Server.add_entry(loor_list,%Todo.List{title: "Going to work", date: ~D[2025-11-13]})
  # > Todo.Server.entries(loor_list, ~D[2025-11-13])
  # > Todo.Server.add_entry(alice_list,%Todo.List{title: "Here we go", date: ~D[2025-11-13]})

  # NB: Alice's list won't be affected by additions to Loorinho's list
end

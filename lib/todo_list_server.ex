defmodule TodoListServer do
  use GenServer

  @impl GenServer
  def init(initial_state) do
    # initial_state is the is bound to the second argument passed into the GenServer.start function
    {:ok, initial_state}
  end

  def start do
    # starts a new process passin in an empty TodoList struct as the initial state
    # spawn(fn -> loop(TodoList.new()) end)

    GenServer.start(TodoListServer, TodoList.new(), name: __MODULE__)
  end

  # defp loop(initial_state) do
  #   new_todo_list =
  #     receive do
  #       # delegates the message to the multiclause function where it is handled
  #       message -> process_message(initial_state, message)
  #     end

  #   loop(new_todo_list)
  # end

  # def add_entry(todo_server, new_entry) do
  #   send(todo_server, {:add_entry, new_entry})
  # end

  def add_entry(new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, new_entry})
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, state) do
    {:noreply, TodoList.add_entry(state, new_entry)}
  end

  @impl GenServer

  def handle_call({:entries, date}, _from, state) do
    {:reply, TodoList.entries(state, date), state}
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  # def entries(todo_server, date) do
  #   send(todo_server, {:entries, self(), date})

  #   receive do
  #     {:todo_entries, entries} -> entries
  #   after
  #     5000 -> {:error, :timeout}
  #   end
  # end

  # defp process_message(todo_list, {:add_entry, new_entry}) do
  #   TodoList.add_entry(todo_list, new_entry)
  # end

  # defp process_message(todo_list, {:entries, caller, date}) do
  #   send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
  #   todo_list
  # end
end

defmodule TodoList do
  defstruct [:date, :title]

  def new do
    %TodoList{}
  end

  def add_entry(todo_list, entry) do
    Map.update(todo_list, entry.date, [entry.title], &[entry.title | &1])

    # Map.update(map, key, default, fun). -If key does not exist in map, it adds it with the default value.
    # - If key exists, it updates the existing value using the function fun.
    # - The default is [value] — meaning if the key is new, it starts a list with one element.
    # - The function is &[value | &1] — meaning if the key already exists, it prepends the new value to the  existing list (&1 is the old list).
  end

  def entries(todo_list, date) do
    Map.get(todo_list, date, [])

    # Retrieves all values stored under a given key. If the key doesn’t exist, it returns an empty list []
  end
end

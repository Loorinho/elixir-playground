defmodule Todo.Server do
  # this line injects several functions into the calling module during compilation
  use GenServer

  @impl GenServer
  def init(name) do
    # The _initial_arg is usually the second argument when we call GenServer.start/2

    # This is us sending a periodic cleanup of the server process state
    # This erlang function periodically sends a message to te caller process
    # :timer.send_interval(5000, :cleanup) <- When uncommented, you'll see the handle_info being invoked

    # This is what the init function returns
    # {:ok, {list_name, Todo.List.new()}}

    IO.puts("Starting to-do server for #{name}.")

    # kinda like Schedules the post-init continuation
    {:ok, {name, nil}, {:continue, :init}}
    # It will split the db initialization into two
  end

  # This callback is usually good to handle long initializations
  # Imagine we want to initialize some data(on hitting the db) during process initialization. It might be a lengthy process. Thats why we split the initialization into two. That way, we don't block the Genserver.start given it only returns after initialization is done.
  @impl GenServer
  def handle_continue(:init, {name, nil}) do
    # The callback receives the arguments from the {:continue, args} tuple as well as the server state
    # nil as the initial state coz we are going to override it anyways

    todo_list = Todo.Database.get(name) || Todo.List.new()

    # above, try to fetch the data from the database, and we resort to the empty list if
    # there’s nothing on disk given that list name

    {:noreply, {name, todo_list}}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    # Since this message isn't a GenServer specific messsage, it's not treated as a cast or call. And so, the handle_info/2 callback is called by the GenServer giving me a chance to deal with the message
    # This function will handle the plain :cleanup message
    IO.puts("Performing cleanup...")
    {:noreply, state}
  end

  # Just good to put on all GenServer callbacks
  # @impl GenServer
  # def handle_cast({:put, entry}, state) do
  #   # First argument is the request and the second argument is the state
  #   {:noreply, Todo.List.add_entry(state, entry)}
  # end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    # Adds the item to the list
    new_list = Todo.List.add_entry(todo_list, new_entry)

    # Persists the new list to the db
    Todo.Database.store(name, new_list)

    # Returns a response
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {name, todo_list}) do
    # _from contains information from the caller like the PID of the caller and the request ID used internally by the GenServer
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end

  # We will then need interface functions to interact with our GenServerStore. There are inbuild functions in the GenServer module like
  # GenServer.start/2 <- To start the gen server
  # GenServer.cast/2 and GenServer.call/2 <- Both used to issue requests to the server

  # Making our own interface functions

  def start(name) do
    # GenServer.start(KeyValueGenServerStore, nil) # initial implementation
    # This line below registers the server process by name. That way, we don't have to always pass the PID in the put and get interface functions

    GenServer.start(Todo.Server, name)
  end

  def add_entry(todo_server, new_entry) do
    # def add_entry(todo) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
    # Here below, we are sending the request to the registered process
    # GenServer.cast(__MODULE__, {:put, todo})
  end

  # def entries(key) do
  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
    # GenServer.call(__MODULE__, {:get, key})
  end

  # Using the named process helps prevent the passing around the pid over and over and it also makes the client facing functions easy to use
end

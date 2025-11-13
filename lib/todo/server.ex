defmodule Todo.Server do
  # this line injects several functions into the calling module during compilation
  use GenServer

  @impl GenServer
  def init(_initial_arg) do
    # The _initial_arg is usually the second argument when we call GenServer.start/2

    # This is us sending a periodic cleanup of the server process state
    # This erlang function periodically sends a message to te caller process
    # :timer.send_interval(5000, :cleanup) <- When uncommented, you'll see the handle_info being invoked

    # This is what the init function returns
    {:ok, %Todo.List{}}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    # Since this message isn't a GenServer specific messsage, it's not treated as a cast or call. And so, the handle_info/2 callback is called by the GenServer giving me a chance to deal with the message
    # This function will handle the plain :cleanup message
    IO.puts("Performing cleanup...")
    {:noreply, state}
  end

  # Just good to put on all GenServer callbacks
  @impl GenServer
  def handle_cast({:put, entry}, state) do
    # First argument is the request and the second argument is the state
    {:noreply, Todo.List.add_entry(state, entry)}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, state) do
    # _from contains information from the caller like the PID of the caller and the request ID used internally by the GenServer
    {:reply, Todo.List.entries(state, key), state}
  end

  # We will then need interface functions to interact with our GenServerStore. There are inbuild functions in the GenServer module like
  # GenServer.start/2 <- To start the gen server
  # GenServer.cast/2 and GenServer.call/2 <- Both used to issue requests to the server

  # Making our own interface functions

  def start do
    # GenServer.start(KeyValueGenServerStore, nil) # initial implementation
    # This line below registers the server process by name. That way, we don't have to always pass the PID in the put and get interface functions
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def add_entry(pid, todo) do
    # def add_entry(todo) do
    GenServer.cast(pid, {:put, todo})
    # Here below, we are sending the request to the registered process
    # GenServer.cast(__MODULE__, {:put, todo})
  end

  # def entries(key) do
  def entries(pid, key) do
    GenServer.call(pid, {:get, key})
    # GenServer.call(__MODULE__, {:get, key})
  end

  # Using the named process helps prevent the passing around the pid over and over and it also makes the client facing functions easy to use
end

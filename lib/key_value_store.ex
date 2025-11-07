defmodule KeyValueStore do
  # This is a simple key value store. A process that can be used to store mappings between arbitrary terms

  # It implements two functions i.e 1. init/0 -> which creates the initial state, 2. handle_call/2 which handles specific requests

  def init do
    %{}
  end

  def handle_call({:put, key, value}, state) do
    # handles the put request
    {:ok, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, state) do
    # Handles the get request
    {Map.get(state, key), state}
  end

  # We can introduce helper functions inorder to make clients completely oblivious to the fact that the GenericServer abstraction was used. That way, the client will call these interface functions instead of calling the generic server directly

  def start do
    GenericServer.start(KeyValueStore)
  end

  def put(pid, key, value) do
    GenericServer.call(pid, {:put, key, value})
  end

  def get(pid, key) do
    GenericServer.call(pid, {:get, key})
  end
end

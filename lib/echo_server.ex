defmodule EchoServer do
  use GenServer

  def start_link(id) do
    IO.puts("Starting process registry")
    Registry.start_link(name: :my_registry, keys: :unique)
    IO.puts("Process registry started...")

    GenServer.start_link(__MODULE__, nil, name: via_tuple(id))
  end

  def init(_) do
    {:ok, nil}
  end

  def call(id, request) do
    # Discovering the server using the via_turple()
    GenServer.call(via_tuple(id), request)
  end

  defp via_tuple(id) do
    {:via, Registry, {:my_registry, {__MODULE__, id}}}
  end

  def handle_call(request, _from, state) do
    {:reply, "Request received is: #{request}", state}
  end
end

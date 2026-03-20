defmodule Todo.ProcessRegistry do
  def start_link do
    # this simply forwards to the Registry module to start a unique registry with its name being the name of the module

    IO.puts("Starting process registry...")
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def via_tuple(complex_name) do
    # The via turple can be used in other modules to register their processes
    {:via, Registry, {__MODULE__, complex_name}}
  end

  def child_spec(_) do
    # Since this registry is a process, it also needs to be supervised. Thats why this child_spec is included so that we don't go with the default specification from the Registry module

    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end

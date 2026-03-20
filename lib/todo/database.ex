defmodule Todo.Database do
  # use GenServer
  # module attribute -> Its the hardcoded value of my local database folder
  @db_folder "./persistance"

  @poolSize 3

  # interface functions for client to interact with
  def start_link do
    IO.puts("Starting database server...")

    # Creating the persistance folder if it doesnt exist
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@poolSize, &db_worker_spec/1)

    # IO.inspect(children, label: "Db workers")

    # Starting the db workers as children under the Database supervisor
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp db_worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}

    # Setting this id is important coz without it, we would end up having multiple children with the same id. Remember if no id is specified, the default is set to the name of the module
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def child_spec(_) do
    # Since it is now our supervisor, we need to provide our own child specification with the type of SUpervisor since we are nolonger in the GenServer territory

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      # Helps us indicate the type of the process which will be started. It can either be :supervisor or :worker -> :worker is the default
      type: :supervisor
    }
  end

  def store(key, data) do
    # Client isn't really expecting a response which is why i went with a cast.
    # Downside is that caller won't know whether request was successfully handled
    # GenServer.cast(__MODULE__, {:store, key, data})

    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @poolSize) + 1
  end
end

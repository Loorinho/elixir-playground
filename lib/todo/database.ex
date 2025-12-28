defmodule Todo.Database do
  use GenServer
  # module attribute -> Its the hardcoded value of my local database folder
  @db_folder "./persistance"

  # interface functions for client to interact with
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
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

    # GenServer.call(__MODULE__, {:get, key})
  end

  # Server functions
  @impl GenServer
  def init(_) do
    # added for polling

    IO.puts("Starting database server")

    # This line below tries to create the database folder if it doesn't exist already
    File.mkdir_p!(@db_folder)
    # {:ok, nil}

    # initializing the three worker processes

    {:ok, start_workers()}
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    key
    |> file_name()
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, 3)
    {:reply, Map.get(workers, worker_key), workers}
  end

  # def handle_call({:get, key}, _, state) do
  #   data =
  #     case File.read(file_name(key)) do
  #       {:ok, contents} -> :erlang.binary_to_term(contents)
  #       _ -> nil
  #     end

  #   {:reply, data, state}
  # end

  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end

  # creating three db worker processes
  defp start_workers() do
    for index <- 1..3, into: %{} do
      # IO.puts("Starting database worker #{index}")
      {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
      {index - 1, pid}
    end
  end
end

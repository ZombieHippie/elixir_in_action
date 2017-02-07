defmodule Todo.Database do
  use GenServer

  # Number of workers to keep in our pool
  @workers 3

  def start(db_folder) do
    GenServer.start(__MODULE__,
      db_folder,
      # Locally register process
      name: :database_server
      )
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  def init(db_folder) do
    # Ensure directory exists
    File.mkdir_p(db_folder)
    workers = start_workers(db_folder)

    {:ok, {db_folder, workers}}
  end

  # Get stored value
  def handle_call({:choose_worker, key}, _, {db_folder, workers}) do
    worker_index = :erlang.phash2(key, @workers)
    worker = Map.get(workers, worker_index)

    IO.inspect { "choose_worker(#{key})", worker_index }

    {:reply, worker, {db_folder, workers}}
  end

  # Needed for testing purposes
  def handle_info(:stop, {db_folder, workers}) do
    workers
    |> Map.values()
    |> Enum.each(&send(&1, :stop))

    {:stop, :normal, {db_folder, Map.new()}}
  end

  defp start_workers(db_folder) do
    for index <- 1..@workers, into: Map.new() do
      {:ok, pid} = Todo.DatabaseWorker.start(db_folder)
      {index - 1, pid}
    end
  end

  defp choose_worker(key) do
    GenServer.call(:database_server, {:choose_worker, key})
  end
end
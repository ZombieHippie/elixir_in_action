defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  def store(worker, key, data) do
    IO.inspect { "WORKER store", worker, key, data }

    GenServer.cast(worker, {:store, key, data})
  end

  def get(worker, key) do
    IO.inspect { "WORKER get", worker, key }

    GenServer.call(worker, {:get, key})
  end

  def init(db_folder) do
    # Ensure directory exists
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  # Store value
  def handle_cast({:store, key, value}, db_folder) do
    file_name(db_folder, key)
    |> File.write!(:erlang.term_to_binary(value))

    {:noreply, db_folder}
  end

  # Get stored value
  def handle_call({:get, key}, _, db_folder) do
    data = case File.read(file_name(db_folder, key)) do
      {:ok, contents} ->
        :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, db_folder}
  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end
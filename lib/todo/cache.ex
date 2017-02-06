defmodule Todo.Cache do
  ### Starting your Todo Cache
  # {:ok, cache} = Todo.Cache.start
  # Todo.Cache.server_process cache, "Bob's list"
  # bobs = Todo.Cache.server_process cache, "Bob's list"
  # Todo.Server.add_entry bobs, %{date: {2017,02,02}, title: "Dentist"}
  # Todo.Server.add_entry bobs, %{date: {2017,02,02}, title: "Movies"}
  ### Populating a bunch of todo servers
  # 1..100_000 |>
  #   Enum.each(fn(index) ->
  #     Todo.Cache.server_process(cache, "to-do list #{index}") end)

  use GenServer

  def init(_) do
    Todo.Database.start("./persist/")
    {:ok, Map.new()}
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        # Server exists in the map
        {:reply, todo_server, todo_servers}

      :error ->
        # Server does not exist
        {:ok, new_server} = Todo.Server.start(todo_list_name)

        {
          :reply,
          new_server,
          Map.put(todo_servers, todo_list_name, new_server)
        }
    end
  end

  def start do
    GenServer.start __MODULE__, nil
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call cache_pid, {:server_process, todo_list_name}
  end
end

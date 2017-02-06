defmodule Todo.Server do
  use GenServer

  def start(name) do
    GenServer.start(Todo.Server, name)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def init(name) do
    send(self(), :setup_state)
    {:ok, {name, nil}}
  end

  def handle_info(:setup_state, {name, _state}) do
    {:noreply, {name, get_state(name) || Todo.List.new()}}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    # Persist the data
    set_state(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      {name, todo_list}
    }
  end

  defp get_state(name) do
    ret = Todo.Database.get("todolist.#{name}")
    IO.puts "get_state #{name}"
    IO.inspect ret
    ret
  end

  defp set_state(name, new_state) do
    Todo.Database.store("todolist.#{name}", new_state)
  end
end



defmodule Todo.List do
  # defstruct [:date, :title]

  def new do
    # %Todo.List{}
    %{}
  end

  def add_entry(todo_list, entry) do
    Map.update(todo_list, entry.date, [entry], &[entry | &1])

    # Map.update(map, key, default, fun). -If key does not exist in map, it adds it with the default value.
    # - If key exists, it updates the existing value using the function fun.
    # - The default is [value] — meaning if the key is new, it starts a list with one element.
    # - The function is &[value | &1] — meaning if the key already exists, it prepends the new value to the  existing list (&1 is the old list).
  end

  def entries(todo_list, date) do
    Map.get(todo_list, date, [])

    # Retrieves all values stored under a given key. If the key doesn’t exist, it returns an empty list []
  end
end

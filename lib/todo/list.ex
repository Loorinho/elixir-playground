defmodule Todo.List do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    # %Todo.List{}

    Enum.reduce(
      entries,
      %Todo.List{},
      &add_entry(&1, &2)
    )
  end

  def size(todo_list) do
    map_size(todo_list.entries)
  end

  # def add_entry(todo_list, entry) do
  #   Map.update(todo_list, entry.date, [entry], &[entry | &1])

  #   # Map.update(map, key, default, fun). -If key does not exist in map, it adds it with the default value.
  #   # - If key exists, it updates the existing value using the function fun.
  #   # - The default is [value] — meaning if the key is new, it starts a list with one element.
  #   # - The function is &[value | &1] — meaning if the key already exists, it prepends the new value to the  existing list (&1 is the old list).
  # end

  def add_entry(todo_list, entry) do
    # adds an id field[Key] to the entry map
    entry = Map.put(entry, :id, todo_list.next_id)
    # puts the entry into the entries map under than given id
    new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)

    # increase next_id by 1 and then return a new struct
    %Todo.List{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def entries(todo_list, date) do
    # This takes all entries ignoring the Ids and filters them based on date returning the list of entries that match the given date

    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  # def entries(todo_list, date) do
  #   Map.get(todo_list, date, [])

  #   # Retrieves all values stored under a given key. If the key doesn’t exist, it returns an empty list []
  # end
end

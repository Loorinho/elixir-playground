defmodule Todo.System do
  # def start_link do
  #   Supervisor.start_link(
  #     [Todo.Cache],
  #     strategy: :one_for_one
  #   )
  # end

  use Supervisor

  # This approach gives more control more so if for example we want to do some extra initializations before starting the children. All this can be done in the init callback
  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    Supervisor.init([Todo.Cache], strategy: :one_for_one)
  end
end

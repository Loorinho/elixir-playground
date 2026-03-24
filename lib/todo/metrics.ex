defmodule Todo.Metrics do
  @moduledoc """
      This module is responsible for collecting system metrics every after 5 seconds
  """

  use Task

  def start_link(_args) do
    # Task.start_link() is good if we dont need to send back a response to the caller
    Task.start_link(&loop/0)
  end

  defp loop do
    Process.sleep(:timer.seconds(5))

    # Fetching metrics
    IO.inspect(collect_metrics())

    loop()
  end

  defp collect_metrics do
    [
      memory_usage: :erlang.memory(:total),
      processes: :erlang.system_info(:process_count)
    ]
  end
end

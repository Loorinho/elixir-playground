defmodule CalculatorServerWithMutableState do
  # TODO: a stateful calculator process that keeps a number as its state.

  def start do
    # This returns the PID of the calculator server
    spawn(fn ->
      initial_state = 0

      loop(initial_state)
    end)
  end

  # loop function will listen in for requests and then delegate to the multi clause process_message function
  defp loop(current_value) do
    new_value =
      receive do
        message -> process_message(current_value, message)
      end

    loop(new_value)
  end

  defp process_message(current_value, {:value, caller}) do
    # handles the case of sending response back to the caller in the value function
    send(caller, {:response, current_value})
    current_value
  end

  defp process_message(current_value, {:add, value}) do
    current_value + value
  end

  defp process_message(current_value, {:sub, value}) do
    current_value - value
  end

  defp process_message(current_value, {:mul, value}) do
    current_value * value
  end

  defp process_message(current_value, {:div, value}) do
    current_value / value
  end

  def value(server_pid) do
    # send the message passing itself as the caller
    send(server_pid, {:value, self()})

    # receive the message in the mailbox if it matches this pattern
    receive do
      {:response, value} ->
        value
    end

    # This function is blocking coz we send a message and then wait for the response
  end

  # The arithmetic operations run asynchronously. There’s no response message, so
  # the caller doesn’t need to wait for anything. When send is invoked, the request is sent to the loop
  # function where it is handled using the appropriate process_message function clause
  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mul(server_pid, value), do: send(server_pid, {:mul, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})
end

defmodule GenericServer do
  def start(callback_module) do
    spawn(fn ->
      # invokes the callback module to initialize the state
      initial_state = callback_module.init()

      loop(callback_module, initial_state)
    end)

    # invoking statrt will return the PID which we can use to send messages to the request process
  end

  defp loop(callback_module, current_state) do
    # This is a synchronous send-and-respond communication pattern. The server process must receive a message, handle it, send the response back to the caller and change the process state

    # The generic server is responsible for receiving and sending messages
    # The Specific implementation (the callback_module) must handle the message and return the response and the new state

    receive do
      # GenericServer process receives the requests and handles then depending on the message tag i.e :call or :cast

      # Handles the :call message -> It is synchronous
      {:call, request, caller} ->
        # the callback_module handles the call request and returns both the response and the new state
        {response, new_state} =
          callback_module.handle_call(
            request,
            current_state
          )

        # GenericServer sends the response back to the caller
        send(caller, {:response, response})

        # Loops with the new state
        loop(callback_module, new_state)

      # Handles the :cast message -> It is assynchronous
      {:cast, request} ->
        new_state =
          callback_module.handle_cast(
            request,
            current_state
          )

        # No response is sent back to the caller, so, the callback ablve only returns the new state
        loop(callback_module, new_state)
    end
  end

  # call is for synchronous requests
  def call(server_pid, request) do
    # sends the message to the server. Captured in the loop function
    # :call tags the message as a call
    send(server_pid, {:call, request, self()})

    # since the loop function sends a response, we must receive the response in here
    receive do
      {:response, response} ->
        response
        # We wait for the response and return the response
    end
  end

  # call is for synchronous requests
  def cast(server_pid, request) do
    # sends the message to the server. Captured in the loop function
    # :cast tags the message as a cast
    send(server_pid, {:cast, request})
  end
end

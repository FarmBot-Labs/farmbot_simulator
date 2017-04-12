defmodule Firmware.PinHandler do
  @moduledoc """
    Handles Pin States.
  """
  use GenServer

  @doc """
    Starts a Pin Handler.
  """
  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, [], opts)

  @doc """
    Sets a value for a pin.
  """
  def set_pin_value(handler, pin, value) do
    GenServer.call(handler, {:set_pin_value, pin, value})
  end

  @doc """
    Gets the current value for a pin.
  """
  def get_pin_value(handler, pin) do
    GenServer.call(handler, {:get_pin_value, pin})
  end

  # GenServer Stuff

  def init([]) do
    {:ok, %{}}
  end

  def handle_call({:set_pin_value, pin, value}, _, state) do
    {:reply, :ok, Map.put(state, pin, value)}
  end

  def handle_call({:get_pin_value, pin}, _, state) do
    {:reply, state[pin], state}
  end

end

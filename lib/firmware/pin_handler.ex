defmodule Firmware.PinHandler do
  use GenServer
  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)
  def init([]) do
    {:ok, %{}}
  end

  def set_pin_value(pin, value) do
    GenServer.call(__MODULE__, {:set_pin_value, pin, value})
  end

  def get_pin_value(pin) do
    GenServer.call(__MODULE__, {:get_pin_value, pin})
  end

  def handle_call({:set_pin_value, pin, value}, _, state) do
    {:reply, :ok, Map.put(state, pin, value)}
  end

  def handle_call({:get_pin_value, pin}, _, state) do
    {:reply, state[pin], state}
  end

end

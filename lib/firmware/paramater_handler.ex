defmodule Firmware.ParamaterHandler do
  use GenServer
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    state =
      Firmware.ParamaterList.params
      |> Map.keys
      |> Map.new(fn(key) ->
        value = Firmware.ParamaterList.get_default(key)
        {key, value}
      end)
    {:ok, state}
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def read_param(param_key) do
    real_key =
      case Integer.parse(param_key) do
        {integer, ""} -> Firmware.ParamaterList.inverse_params[integer]
        _ -> param_key
      end
    GenServer.call(__MODULE__, {:read, real_key})
  end

  def set_param(param_key, value) do
    real_key =
      case Integer.parse(param_key) do
        {integer, ""} -> Firmware.ParamaterList.inverse_params[integer]
        _ -> param_key
      end
    GenServer.call(__MODULE__, {:set, real_key, value})
  end

  def handle_call(:get_state, _, state), do: {:reply, state, state}

  def handle_call({:read, param_key}, _, state) do
    reply = state[param_key]
    {:reply, reply, state}
  end

  def handle_call({:set, param_key, value}, _, state) do
    {:reply, :ok, %{state | param_key => value}}
  end
end

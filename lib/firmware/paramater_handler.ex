defmodule Firmware.ParamaterHandler do
  @moduledoc """
    Handles paramaters state.
  """

  use GenServer
  alias Firmware.ParamaterList
  require Logger

  @doc """
    Starts a paramater handler.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @doc """
    Read a paramater by its key
  """
  def read_param(handler, param_key) do
    real_key =
      case Integer.parse(param_key) do
        {integer, ""} -> ParamaterList.inverse_params[integer]
        _ -> param_key
      end
    GenServer.call(handler, {:read, real_key})
  end

  @doc """
    Write a paramater by its key
  """
  def set_param(handler, param_key, value) do
    real_key =
      case Integer.parse(param_key) do
        {integer, ""} ->
          ParamaterList.inverse_params[integer] || print_unhandled(param_key)
        _ -> param_key
      end
    GenServer.call(handler, {:set, real_key, value})
  end

  # GenServer Stuff

  def init([]) do
    state =
      ParamaterList.params
      |> Map.keys
      |> Map.new(fn(key) ->
        value = ParamaterList.get_default(key)
        {key, value}
      end)
    {:ok, state}
  end

  def handle_call({:read, param_key}, _, state) do
    reply = state[param_key]
    {:reply, reply, state}
  end

  def handle_call({:set, nil, _value}, _, state), do: {:reply, :ok, state}

  def handle_call({:set, param_key, value}, _, state) do
    {:reply, :ok, %{state | param_key => value}}
  end

  defp print_unhandled(param_key) do
    Logger.warn "UNHANDLED KEY: #{param_key}"
    nil
  end
end

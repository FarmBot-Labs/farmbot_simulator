defmodule Firmware.PositionHandler do
  @moduledoc """
    Handles Current Position.
  """
  use GenServer

  @doc """
    Starts a Position Handler.
  """
  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, [], opts)

  @doc """
    Sets bot position
  """
  def set_pos(handler, position)
  def set_pos(han, {_x, _y, _z} = p), do: GenServer.call(han, {:set_pos, p})

  @doc """
    Gets the current position.
  """
  def get_pos(handler), do: GenServer.call(handler, :get_pos)

  # GenServer Stuff

  def init([]), do: {:ok, {0,0,0}}
  def handle_call(:get_pos, _, pos), do: {:reply, pos, pos}
  def handle_call({:set_pos, pos}, _, _), do: {:reply, pos, pos}
end

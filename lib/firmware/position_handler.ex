defmodule Firmware.PositionHandler do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init([]) do
    {:ok, {0,0,0}}
  end

  def set_pos(pos), do: GenServer.call(__MODULE__, {:set_pos, pos})

  def get_pos, do: GenServer.call(__MODULE__, :get_pos)

  def handle_call(:get_pos, _, pos), do: {:reply, pos, pos}

  def handle_call({:set_pos, pos}, _, _), do: {:reply, pos, pos}
end

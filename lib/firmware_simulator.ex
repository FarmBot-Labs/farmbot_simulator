defmodule FirmwareSimulator do
  @moduledoc """
    Simulates farmbot-arduino-firmware
  """

  use GenServer
  require Logger
  alias Nerves.UART

  @tty "/dev/tnt0"

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Logger.info "Starting Firmware Simulator"
    {:ok, nerves} = UART.start_link()
    {:ok, param_handler} = Firmware.ParamaterHandler.start_link()
    {:ok, pos_handler} = Firmware.PositionHandler.start_link()
    {:ok, pin_handler} = Firmware.PinHandler.start_link()
    :ok = UART.open(nerves, @tty,
      [active: true, speed: 115200,
      framing: {Nerves.UART.Framing.Line, separator: "\r\n"}
      ])
    {:ok, %{
      nerves: nerves,
      param_handler: param_handler,
      position_handler: pos_handler,
      pin_handler: pin_handler
      }}
  end

  def handle_info({:nerves_uart, @tty, str}, state) do
    cmd = String.split(str, " ")
    qcode = find_qcode(cmd)
    do_write(state.nerves, "R01 #{qcode}")
    reply = Firmware.CodeHandler.handle_code(cmd)
    case reply do
      # if we just have one binary, write it.
      blerp when is_binary(blerp) ->
        :ok = do_write(state.nerves, blerp)

      # if we have a list of binaries, write them sequentially
      flerp when is_list(flerp) ->
        do_write_multi(state.nerves, flerp)

      # not doing anything is fine too.
      :noreply -> :ok

      # if no handler for this code, warn.
      nil ->
        Logger.warn("unhandled command: #{str}")
    end

    do_write(state.nerves, "R02 #{qcode}")
    {:noreply, state}
  end

  def handle_info(info, state) do
    Logger.info("Got unhandled info: #{inspect info}")
    {:noreply, state}
  end

  def handle_call({:write, str}, _, state) do
    :ok = do_write(state.nerves, str)
    {:reply, :ok, state}
  end

  def terminate(_reason, state) do
    UART.stop(state.nerves)
  end

  @spec do_write(pid, binary) :: :ok | {:error, term}
  defp do_write(nerves, str), do: UART.write(nerves, str)

  @spec do_write_multi(pid, [binary]) :: :ok | no_return
  defp do_write_multi(_, []), do: :ok
  defp do_write_multi(nerves, [str | rest]) do
    :ok = do_write(nerves, str)
    Process.sleep(100)
    do_write_multi(nerves, rest)
  end

  defp find_qcode([]), do: "Q69"
  defp find_qcode([head | tail]) do
    case head do
      "Q" <> _code -> head
      _ -> find_qcode(tail)
    end
  end

  def write(str) do
    GenServer.call(__MODULE__, {:write, str})
  end

  def stop(reason \\ :normal) do
    GenServer.stop(__MODULE__, reason)
  end
end

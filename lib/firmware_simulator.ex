defmodule FirmwareSimulator do
  @moduledoc """
    Simulates farmbot-arduino-firmware
  """

  use GenServer
  require Logger
  alias Nerves.UART
  alias Firmware.{ParamaterHandler, PositionHandler, PinHandler, CodeHandler}

  @tty "/dev/tnt0"

  @type state :: %{
    nerves: pid,
    param_handler: pid,
    position_handler: pid,
    pin_handler: pid
  }

  @doc """
    Start the simulated Farmbot Simulator.
  """
  def start_link(tty \\ @tty, opts \\ []),
    do: GenServer.start_link(__MODULE__, tty, opts)

  @doc """
    Writes a string to the simulators Serial Line.
  """
  def write(sim, str), do: GenServer.call(sim, {:write, str})

  @doc """
    Stops a simulator.
  """
  def stop(sim, reason \\ :normal), do: GenServer.stop(sim, reason)

  # GenServer Stuff

  def init(tty) do
    Logger.info "Starting Firmware Simulator: #{tty}"
    Logger.info "You can connect your device to: /dev/tnt1"
    {:ok, nerves} = UART.start_link()
    {:ok, param_handler} = ParamaterHandler.start_link()
    {:ok, pos_handler} = PositionHandler.start_link()
    {:ok, pin_handler} = PinHandler.start_link()
    :ok = UART.open nerves, tty,
      [
        active: true, speed: 115200,
        framing: {UART.Framing.Line, separator: "\r\n"}
      ]
    timer = Process.send_after(self(), :idle_timer, 6000)
    {:ok, %{
      q: nil,
      timer: timer,
      nerves: nerves,
      param_handler: param_handler,
      position_handler: pos_handler,
      pin_handler: pin_handler
      }}
  end

  def handle_info({:nerves_uart, _tty, str}, state) do
    if state.timer do
      Process.cancel_timer(state.timer)
    end
    cmd = String.split(str, " ")
    qcode = find_qcode(cmd)
    do_write(state.nerves, "R01 #{qcode}")
    reply = CodeHandler.handle_code(cmd, state)
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

    timer = Process.send_after(self(), :idle_timer, 6000)

    do_write(state.nerves, "R02 #{qcode}")
    {:noreply, %{state | timer: timer, q: qcode}}
  end

  def handle_info(:idle_timer, state) do
    do_write(state.nerves, "R00 Q#{state.q || 0}")
    timer = Process.send_after(self(), :idle_timer, 6000)
    {:noreply, %{state | timer: timer}}
  end

  def handle_info(info, state) do
    Logger.info("Got unhandled info: #{inspect info}")
    {:noreply, state}
  end

  def handle_call({:write, str}, _, state) do
    :ok = do_write(state.nerves, str)
    {:reply, :ok, state}
  end

  def terminate(_reason, state), do: UART.stop(state.nerves)

  # Private

  @spec do_write(pid, binary) :: :ok | {:error, term}
  defp do_write(nerves, str), do: UART.write(nerves, str)

  @spec do_write_multi(pid, [binary]) :: :ok | no_return
  defp do_write_multi(_, []), do: :ok
  defp do_write_multi(nerves, [str | rest]) do
    :ok = do_write(nerves, str)
    Process.sleep(100)
    do_write_multi(nerves, rest)
  end

  defp find_qcode([]), do: "Q#{Enum.random(0..99)}"
  defp find_qcode([head | tail]) do
    case head do
      "Q" <> _code -> head
      _ -> find_qcode(tail)
    end
  end
end

defmodule FirmwareSimulator do
  @moduledoc """
    Simulates farmbot-arduino-firmware
  """

  use GenServer
  require Logger
  alias Nerves.UART
  alias Firmware.{ParamaterHandler, PositionHandler, PinHandler, CodeHandler}


  @type state :: %{
    nerves: pid,
    param_handler: pid,
    position_handler: pid,
    pin_handler: pid
  }

  @doc """
    Start the simulated Farmbot Simulator.
  """
  def start_link(tty, opts \\ []),
    do: GenServer.start_link(__MODULE__, tty, opts)

  @doc """
    Writes a string to the simulators Serial Line.
  """
  def write(sim, str), do: GenServer.call(sim, {:write, str})

  @doc """
    Stops a simulator.
  """
  def stop(sim, reason \\ :normal), do: GenServer.stop(sim, reason)

  defp wait_for_connect(nerves, tty) do
    case UART.write(nerves, "R00 Q0") do
      {:error, :einval} ->
        UART.close(nerves)
        :ok = open_tty(nerves, tty)
        IO.puts "waiting for connection.."
        Process.sleep(2000)
        wait_for_connect(nerves, tty)
      :ok -> :ok
    end
  end

  defp open_tty(nerves, tty) do
    UART.open nerves, tty,
      [
        active: true, speed: 115200,
        framing: {UART.Framing.Line, separator: "\r\n"}
      ]
  end

  # GenServer Stuff

  def init(tty) do
    Logger.info "Starting Firmware Simulator: #{tty}"
    Logger.info "You can connect your device to: #{tty}"
    {:ok, nerves} = UART.start_link()
    {:ok, param_handler} = ParamaterHandler.start_link()
    {:ok, pos_handler} = PositionHandler.start_link()
    {:ok, pin_handler} = PinHandler.start_link()
    :ok = open_tty(nerves, tty)
    :ok = wait_for_connect(nerves, tty)
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

  def handle_info({:nerves_uart, _tty, str}, state) when is_binary(str) do
    # IO.puts "reading #{str}"
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

  def handle_info({:nerves_uart, tty, {:error, :ebadf}}, state) when is_binary(tty)  do
    UART.close(state.nerves)
    :ok = open_tty(state.nerves, tty)
    {:noreply, state}
  end

  def handle_info({:nerves_uart, nil, _data}, state), do: {:noreply, state}

  def handle_info({:nerves_uart, tty, data}, state)  do
    Logger.warn "Farmbot Simulator got unhandled data: #{inspect data} on tty: #{tty}"
    {:noreply, state}
  end


  def handle_info(:idle_timer, state) do
    # IO.puts "got idle timer"
    :ok = do_write(state.nerves, "R00 Q#{state.q || 0}")
    timer = Process.send_after(self(), :idle_timer, 6000)
    {:noreply, %{state | timer: timer}}
  end

  def handle_info(info, state) do
    Logger.info("Got unhandled info: #{inspect info}")
    {:noreply, state}
  end

  def handle_call({:write, str}, _, state) when is_binary(str) do
    :ok = do_write(state.nerves, str)
    {:reply, :ok, state}
  end

  def terminate(_reason, state), do: UART.stop(state.nerves)

  # Private

  @spec do_write(pid, binary) :: :ok | {:error, term}
  defp do_write(nerves, str) when is_pid(nerves) and is_binary(str) do
    # IO.puts "writing #{str}"
    # require IEx
    # IEx.pry
    UART.write(nerves, str)
  end

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

defmodule Firmware.CodeHandler.F42 do
  @moduledoc false
  @behaviour Firmware.CodeHandler

  @doc false
  def run(["P" <> pin, "M" <> _mode, qcode], %{pin_handler: ph}) do
    value = Firmware.PinHandler.get_pin_value(ph, pin)
    "R41 P#{pin} V#{value} #{qcode}"
  end
end

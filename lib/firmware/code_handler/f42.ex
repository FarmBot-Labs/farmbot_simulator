defmodule Firmware.CodeHandler.F42 do
  @moduledoc false
  @behaviour Firmware.CodeHandler
  def run(["P" <> pin, "M" <> _mode, qcode]) do
    value = Firmware.PinHandler.get_pin_value(pin)
    "R41 P#{pin} V#{value} #{qcode}"
  end
end

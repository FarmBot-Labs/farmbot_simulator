defmodule Firmware.CodeHandler.F41 do
  @moduledoc false
  @behaviour Firmware.CodeHandler
  def run(["P" <> pin, "V" <> value, "M" <> _mode, _qcode]) do
    Firmware.PinHandler.set_pin_value(pin, value)
    :noreply
  end
end

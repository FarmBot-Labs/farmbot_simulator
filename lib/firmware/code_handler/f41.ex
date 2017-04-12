defmodule Firmware.CodeHandler.F41 do
  @moduledoc false
  @behaviour Firmware.CodeHandler

  @doc false
  def run(["P" <> pin, "V" <> value, "M" <> _mode, _qcode], %{pin_handler: ph}) do
    Firmware.PinHandler.set_pin_value(ph, pin, value)
    :noreply
  end
end

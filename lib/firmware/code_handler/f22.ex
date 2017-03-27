defmodule Firmware.CodeHandler.F22 do
  @moduledoc false
  @behaviour Firmware.CodeHandler
  def run(["P" <> id, "V" <> value, _qcode]) do
    Firmware.ParamaterHandler.set_param(id, value)
    :noreply
  end
end

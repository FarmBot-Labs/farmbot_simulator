defmodule Firmware.CodeHandler.F22 do
  @moduledoc false
  @behaviour Firmware.CodeHandler
  def run(["P" <> id, "V" <> value, _qcode],  %{param_handler: ph}) do
    Firmware.ParamaterHandler.set_param(ph, id, value)
    :noreply
  end
end

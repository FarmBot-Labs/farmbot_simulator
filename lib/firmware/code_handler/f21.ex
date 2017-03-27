defmodule Firmware.CodeHandler.F21 do
  @moduledoc false
  @behaviour Firmware.CodeHandler

  def run(["P" <> id, qcode]) do
    "R21 P#{id} V#{Firmware.ParamaterHandler.read_param(id)} #{qcode}"
  end
end

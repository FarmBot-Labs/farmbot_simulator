defmodule Firmware.CodeHandler.F21 do
  @moduledoc false
  @behaviour Firmware.CodeHandler

  @doc false
  def run(["P" <> id, qcode], %{param_handler: ph}) do
    "R21 P#{id} V#{Firmware.ParamaterHandler.read_param(ph, id)} #{qcode}"
  end
end

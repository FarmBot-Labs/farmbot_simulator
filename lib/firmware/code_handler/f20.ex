defmodule Firmware.CodeHandler.F20 do
  @moduledoc false
  @behaviour Firmware.CodeHandler

  def run(args) do
    Enum.map(Firmware.ParamaterList.params, fn({param, id}) ->
      "R21 P#{id} V#{Firmware.ParamaterHandler.read_param(param)} #{args}"
    end)
  end
end

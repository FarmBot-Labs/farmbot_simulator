defmodule Firmware.CodeHandler.F20 do
  @moduledoc false
  @behaviour Firmware.CodeHandler

  @doc false
  def run(args, context) do
    ph = context.param_handler
    Enum.map(Firmware.ParamaterList.params, fn({param, id}) ->
      "R21 P#{id} V#{Firmware.ParamaterHandler.read_param(ph, param)} #{args}"
    end)
  end
end

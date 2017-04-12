defmodule Firmware.CodeHandler.G00 do
  @moduledoc false
  alias Firmware.{CodeHandler, ParamaterHandler, PositionHandler}
  @behaviour CodeHandler

  @doc false
  def run(["X" <> x, "Y" <> y, "Z" <> z, "S" <> _s, qcode], context) do
    # Set up context
    position_handler = context[:position_handler]
    param_handler = context[:param_handler]

    # Do some magic.
    [x, y, z] = Enum.map([{x, :x},{y, :y},{z, :z}], fn({val, axis}) ->
      rval = String.to_integer(val)
      axis_str = Atom.to_string(axis) |> String.Casing.upcase()
      blerp = ParamaterHandler.read_param(param_handler, "MOVEMENT_HOME_UP_#{axis_str}")
      allow_neg = blerp |> to_bool

      # if negative, maybe allow negatives
      if rval < 0 do
        maybe_allow_neg(rval, allow_neg)
      else
        rval
      end
    end)

    PositionHandler.set_pos(position_handler, {x, y, z})
    "R82 X#{x} Y#{y} Z#{z} #{qcode}"
  end

  defp to_bool(1), do: true
  defp to_bool(0), do: false
  defp to_bool("1"), do: true
  defp to_bool("0"), do: false

  defp maybe_allow_neg(rval, true), do: rval
  defp maybe_allow_neg(_, false), do: 0
end

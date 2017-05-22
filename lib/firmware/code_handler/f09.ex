defmodule Firmware.CodeHandler.F09 do
  @moduledoc false
  @behaviour Firmware.CodeHandler

  @doc false
  def run([], _) do
    "R00"
  end
end

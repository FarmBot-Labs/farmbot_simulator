defmodule Firmware.CodeHandler.E do
  @moduledoc false
  @behaviour Firmware.CodeHandler

  @doc false
  def run([], _) do
    "R87"
  end
end

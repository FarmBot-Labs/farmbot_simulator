defmodule Firmware.CodeHandler do
  @moduledoc """
    delagates codes
  """

  require Logger

  @type context :: FirmwareSimulator.state

  @callback run([binary], context) :: binary | :noreply | [binary] | nil

  # Thanks past me.
  # _gcode =
  # "lib/firmware/code_handler/"
  # |> File.ls!
  # |> Enum.reduce([], fn(file_name, acc) ->
  #   case String.split(file_name, ".ex") do
  #     [file_name, ""] ->
  #       # IO.puts "defining #{file_name}"
  #       mod = Module.concat Firmware.CodeHandler,
  #         Macro.camelize(file_name)
  #       [{String.to_atom(file_name), mod} | acc]
  #     _ -> acc
  #   end
  # end)

  @spec handle_code([binary], context) :: nil | :noreply | binary | [binary]
  def handle_code([code | args], context) do
    mod = Module.concat [__MODULE__, code]
    try do
      Logger.debug "Doing: #{code}"
      apply(mod, :run, [args, context])
    rescue
      e ->
        Logger.error("Error doing #{code} #{inspect e}")
        # Just return nil so we dont crash. We will get a good message on what
        # Wasnt handled in the shell
        nil
    end
  end
end

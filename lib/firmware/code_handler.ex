defmodule Firmware.CodeHandler do
  @moduledoc """
    delagates codes
  """

  require Logger
  @callback run([binary]) :: binary | :noreply | [binary] | nil

  # Thanks past me.
  gcode =
  "lib/firmware/code_handler/"
  |> File.ls!
  |> Enum.reduce([], fn(file_name, acc) ->
    case String.split(file_name, ".ex") do
      [file_name, ""] ->
        # IO.puts "defining #{file_name}"
        mod = Module.concat Firmware.CodeHandler,
          Macro.camelize(file_name)
        [{String.to_atom(file_name), mod} | acc]
      _ -> acc
    end
  end)

  # I don't think this is actually needed.
  for {fun, module} <- gcode do
    defdelegate unquote(fun)(args), to: module, as: :run
  end

  @spec handle_code([binary]) :: nil | :noreply | binary | [binary]
  def handle_code([code | args]) do
    mod = Module.concat [__MODULE__, code]
    try do
      Logger.debug "Doing: #{code}"
      apply(mod, :run, [args])
    rescue
      e ->
        Logger.error("Error doing #{code} #{inspect e}")
        # Just return nil so we dont crash. We will get a good message on what
        # Wasnt handled in the shell
        nil
    end
  end
end

defmodule Firmware.ParamaterList do
  @moduledoc """
  automatically generated from the paramater list text file.
  """
  require Logger

  code_dir = "#{:code.priv_dir(Mix.Project.config[:app])}"

  @params File.read!("#{code_dir}/paramater_list.txt")
    |> String.replace("\t", "")
    |> String.replace("= ", "=")
    |> String.replace(" =", "=")
    |> String.replace(" = ", "=")
    |> String.replace(",", "")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn(str) ->
      [param | [int]] = String.split(str, "=")
      param = String.trim(param)
      IO.puts "Defining #{param}: #{int}"
      {param, String.to_integer(int)}
    end)
    |> Map.new

  @defaults File.read!("#{code_dir}/paramater_defaults.txt")
    |> String.replace("\t", "")
    |> String.replace(" ", "")
    |> String.replace("= ", "=")
    |> String.replace(" =", "=")
    |> String.replace(" = ", "=")
    |> String.replace(";", "")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn(str) ->
      [param | [int]] = String.split(str, "=")
      param_default = String.trim(param, "_DEFAULT") |> String.trim()
      IO.puts "Setting default #{param_default}: #{int}"
      {param_default, String.to_integer(int)}
    end)
    |> Map.new

  @doc """
  map of params indexed by param name
  """
  def params, do: @params

  @doc """
  Map of params indexed by integer
  """
  def inverse_params, do: Enum.map(@params, fn({key, value}) ->
    {value, key}
  end) |> Map.new

  @doc """
  map of param defaults indexed by param name.
  """
  def defaults, do: @defaults

  @doc """
  gets the default value for given key
  """
  def get_default(key), do: Map.get(defaults(), key, nil) || no_default(key)

  defp no_default(key) do
    Logger.warn "No default for: #{key}"
    -1
  end
end

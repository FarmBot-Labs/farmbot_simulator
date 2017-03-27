defmodule Firmware.ParamaterList do
  @moduledoc """
  automatically generated from the paramater list text file.
  """

  @params File.read!("priv/paramater_list.txt")
    |> String.replace("\t", "")
    |> String.replace("= ", "=")
    |> String.replace(" =", "=")
    |> String.replace(",", "")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn(str) ->
      [param | [int]] = String.split(str, "=")
      {param, String.to_integer(int)}
    end)
    |> Map.new

  @defaults File.read!("priv/paramater_defaults.txt")
    |> String.replace("\t", "")
    |> String.replace(" ", "")
    |> String.replace("= ", "=")
    |> String.replace(" =", "=")
    |> String.replace(";", "")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn(str) ->
      [param | [int]] = String.split(str, "=")
      {String.trim(param, "_DEFAULT"), String.to_integer(int)}
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
  def get_default(key), do: Map.get(defaults(), key, -1)
end

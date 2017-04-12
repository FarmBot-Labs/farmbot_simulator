defmodule Firmware.CodeHandler.F83 do
  @moduledoc false
  @behaviour Firmware.CodeHandler
  @version_info "FIRMWARE SIMULATOR #{Mix.Project.config[:version]}"

  @doc false
  def run(args, _context), do: "R83 #{@version_info} #{args}"
end

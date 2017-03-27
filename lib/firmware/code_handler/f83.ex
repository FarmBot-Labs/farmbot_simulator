defmodule Firmware.CodeHandler.F83 do
  @moduledoc false
  @behaviour Firmware.CodeHandler
  @version_info "FIRMWARE SIMULATOR #{Mix.Project.config[:version]}"
  def run(args), do: "R83 #{@version_info} #{args}"
end

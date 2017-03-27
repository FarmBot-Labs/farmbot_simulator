defmodule FarmbotSimulator do
  @moduledoc """
  Entry Point for FarmbotSimulator
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      # worker(BotSimulator, [], [restart: :permanent]),
      worker(FirmwareSimulator, [], [restart: :permanent])
    ]
    opts = [strategy: :one_for_all, name: Blah.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

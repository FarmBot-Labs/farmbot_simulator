defmodule FarmbotSimulator do
  @moduledoc """
  Entry Point for FarmbotSimulator
  """
  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    tty = Application.fetch_env!(:farmbot_simulator, :tty)
    children = [
      # worker(BotSimulator, [], [restart: :permanent]),
      worker(FirmwareSimulator, [tty], [restart: :permanent])
    ]
    opts = [strategy: :one_for_all, name: Blah.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

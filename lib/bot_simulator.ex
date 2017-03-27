defmodule BotSimulator do
  @app Mix.Project.config[:app]
  use GenServer
  require Logger

  @doc """
  Start The Simulator
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Logger.info "Starting Bot Simulator"
    exe = "#{:code.priv_dir(@app)}/#{Mix.env()}/fbsim" |> Path.absname
    opts = [:binary, args: []]
    port = Port.open({:spawn_executable, exe}, opts)
    {:ok, %{port: port}}
  end

  def handle_info(info, state) do
    Logger.info("unhandled info:  #{inspect info}")
    {:noreply, state}
  end

  def terminate(_reason, state) do
    Port.command(state.port, "EXIT")
    # Port.close(state.port)
  end
end

defmodule FarmbotSimulator.Mixfile do
  use Mix.Project

  def project do
    [app: :farmbot_simulator,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:elixir_make] ++ Mix.compilers,
     deps: deps()]
  end

  def application do
    [ mod: {FarmbotSimulator, []},
      extra_applications: [
      :logger,
      :nerves_uart
    ]]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:nerves_uart, "~> 0.1.2"}
    ]
  end
end

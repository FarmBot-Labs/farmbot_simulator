defmodule FarmbotSimulator.Mixfile do
  use Mix.Project

  def project do
    [app: :farmbot_simulator,
     version: "0.1.3",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: Mix.compilers,
     description: description(),
     package: package(),
     name: "Farmbot Simulator",
     source_url: "https://github.com/FarmBot-Labs/farmbot_simulator",
     homepage_url: "https://farmbot.io",
     docs: [
       main: "FarmbotSimulator",
       extras: ["README.md"]
     ],
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
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:nerves_uart, "~> 0.1.2"}
    ]
  end

  defp description do
    """
    Simulates (NOT EMULATES) Farmbot's arduino firmware and hardware.
    The firmware is pretty stable and used in FarmbotOS's testing environment.
    The visual hardware simulator is very much a WIP.
    """
  end

  defp package do
    [
      name: :farmbot_simulator,
      files: ["lib",
        "config",
        "priv",
        "src",
        "Makefile",
        ".gitignore",
        "mix.exs",
        "mix.lock",
        "README.md",
        "LICENSE"
      ],
      licenses: ["MIT"],
      maintainers: ["Connor Rigby"],
      links: %{
        "GitHub" => "https://github.com/FarmBot-Labs/farmbot_simulator",
        "Docs" => "https://hexdocs.pm/farmbot_simulator/"
      }
    ]
  end
end

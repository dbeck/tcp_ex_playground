defmodule TcpExPlayground.Mixfile do
  use Mix.Project

  def project do
    [app: :tcp_ex_playground,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [ applications: [:logger, :ranch],
      mod: {TcpExPlayground, []} ]
  end

  defp deps do
    [{:ranch, "~> 1.1"}]
  end
end

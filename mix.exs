defmodule BidirectionalTyping.MixProject do
  use Mix.Project

  def project do
    [
      app: :bidirectional_typing,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # do I need this?
  def application, do: [extra_applications: [:logger]]

  defp deps, do: []
end

defmodule FileSystemUtils.MixProject do
  use Mix.Project

  def project do
    [
      app: :file_system_utils,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [markdown_processor: ExDoc.Markdown.Cmark]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:cmark, "~> 0.6", only: :dev},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end

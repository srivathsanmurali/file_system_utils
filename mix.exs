defmodule FileSystemUtils.MixProject do
  use Mix.Project

  def project do
    [
      app: :file_system_utils,
      name: "file_system_utils",
      version: "0.4.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [markdown_processor: ExDoc.Markdown.Cmark],
      source_url: "https://github.com/srivathsanmurali/file_system_utils"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  defp description() do
    "Wrapper around common file system linux utilties."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:cmark, "~> 0.6", only: :dev},
      {:ex_doc, "~> 0.19.1", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      name: "file_system_utils",
      maintainers: ["Srivathsan Murali"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/srivathsanmurali/file_system_utils"}
    ]
  end
end

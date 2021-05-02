defmodule NavigationHistory.Mixfile do
  use Mix.Project

  @source_url "https://github.com/tuvistavie/plug-navigation-history"
  @version "0.3.0"

  def project do
    [
      app: :navigation_history,
      name: "navigation_history",
      version: @version,
      elixir: "~> 1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  defp package do
    [
      description: "Navigation history tracking plug",
      files: ["lib", "mix.exs", "LICENSE", "README.md"],
      maintainers: ["Daniel Perez"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  def application do
    [
      applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: [{:"LICENSE", [title: "License"]}, "README.md"],
      main: "readme",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end
end

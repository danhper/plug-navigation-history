defmodule NavigationHistory.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :navigation_history,
     name: "navigation_history",
     version: @version,
     source_url: "https://github.com/tuvistavie/plug-navigation-history",
     homepage_url: "https://github.com/tuvistavie/plug-navigation-history",
     package: package,
     elixir: "~> 1.0",
     description: description,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     license: "MIT",
     deps: deps]
  end

  defp package do
    [files: ["lib", "mix.exs", "LICENSE", "README.md"],
     maintainers: ["Daniel Perez"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/tuvistavie/plug-navigation-history"}]
  end

  defp description do
    "Navigation history tracking plug"
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:plug, "~> 1.1"},
     {:earmark, "~> 0.2", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
  end
end

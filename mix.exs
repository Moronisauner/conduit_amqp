defmodule ConduitAmqp.Mixfile do
  use Mix.Project

  def project do
    [app: :conduit_amqp,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,

     # Docs
     name: "ConduitAMQP",
     source_url: "https://github.com/conduitframework/conduit_amqp",
     homepage_url: "https://hexdocs.pm/conduit_amqp",
     docs: docs,

     # Package
     description: "AMQP adapter for Conduit.",
     package: package,

     dialyzer: [flags: ["-Werror_handling", "-Wrace_conditions"]],

     # Coveralls
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.circle": :test],

     aliases: ["publish": ["hex.publish", &git_tag/1]]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :amqp, :poolboy, :connection, :conduit]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:amqp, "~> 0.1", hex: :amqp19},
     {:connection, "~> 1.0"},
     {:poolboy, "~> 1.5"},
     {:conduit, "~> 0.5"},
     {:ex_doc, "~> 0.14", only: :dev},
     {:dialyxir, "~> 0.4", only: :dev},
     {:excoveralls, "~> 0.5", only: :test}]
  end

  defp package do
    [# These are the default files included in the package
     name: :conduit_amqp,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Allen Madsen"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/conduitframework/conduit_amqp",
              "Docs" => "https://hexdocs.pm/conduit_amqp"}]
  end

  defp docs do
    [main: "readme",
     project: "ConduitAMQP",
     extra_section: "Guides",
     extras: ["README.md"],
     assets: ["assets"]]
  end

  defp git_tag(_args) do
    tag = "v" <> Mix.Project.config[:version]
    System.cmd("git", ["tag", tag])
    System.cmd("git", ["push", "origin", tag])
  end
end

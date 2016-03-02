defmodule SlackLoggerBackend.Mixfile do
  use Mix.Project

  def project do
    [
      app: :slack_logger_backend,
      description: "A logger backend for posting errors to Slack.",
      version: "0.1.2",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
      package: package
    ]
  end

  def application do
    [applications: [:logger, :httpoison],
    mod: {SlackLoggerBackend, []}]
  end

  defp deps do
    [
      {:httpoison, "~> 0.8"},
      {:poison, "~> 2.1"},
      {:excoveralls, "~> 0.4", only: :test},
      {:earmark, "~> 0.2", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:dialyxir, "~> 0.3", only: :dev},
      {:credo, "~> 0.2", only: :dev},
      {:bypass, "~> 0.1", only: :test},
      {:inch_ex, only: :docs}
    ]
  end

  def package do
    [
      files: ["lib", "mix.exs", "README*"],
      licenses: ["MIT"],
      maintainers: ["Craig Paterson"],
      links: %{"Github" => "https://github.com/craigp/slack_logger_backend"}
    ]
  end
end

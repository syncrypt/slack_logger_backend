use Mix.Config

config :slack_logger_backend, :levels, [:debug, :info, :warn, :error]
config :slack_logger_backend, :slack, [url: "http://example.com"]

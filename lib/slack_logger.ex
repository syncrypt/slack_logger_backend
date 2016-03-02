defmodule SlackLogger do

  @moduledoc """
  Does the actual work of posting to Slack.
  """

  use GenEvent

  @env_webhook "SLACK_LOGGER_WEBHOOK_URL"

  @doc false
  def init(__MODULE__) do
    levels = case Application.get_env(:slack_logger_backend, :levels) do
      nil ->
        [:error] # by default only log error level messages
      levels ->
        levels
    end
    {:ok, %{levels: levels}}
  end

  @doc false
  def handle_call(_request, state) do
    {:ok, state}
  end

  @doc false
  def handle_event({level, _pid, {Logger, message, _timestamp, detail}}, %{levels: levels} = state) do
    if level in levels do
      handle_event(level, message, detail)
    end
    {:ok, state}
  end

  @doc false
  def handle_info(_message, state) do
    {:ok, state}
  end

  defp get_url do
    unless System.get_env(@env_webhook) do
      Application.get_env(:slack_logger_backend, :slack)[:url]
    end
  end

  defp handle_event(level, message, [pid: _source_pid, module: module, function: function, file: file, line: line]) do
    {:ok, json} = Poison.encode(%{text: """
      An event has occurred: _#{message}_
      *Level*: #{level}
      *Module*: #{module}
      *Function*: #{function}
      *File*: #{file}
      *Line*: #{line}
      """})
    get_url |> HTTPoison.post(json)
  end

  defp handle_event(_, _, _) do
    :noop
  end

end

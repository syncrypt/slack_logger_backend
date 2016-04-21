defmodule SlackLogger do

  @moduledoc """
  Does the actual work of posting to Slack.
  """

  use GenEvent

  @env_webhook "SLACK_LOGGER_WEBHOOK_URL"

  @doc false
  def init(__MODULE__) do
    {:ok, %{}}
  end

  @doc false
  def handle_call(_request, state) do
    {:ok, state}
  end

  @doc false
  def handle_event({level, _pid, {Logger, message, _timestamp, detail}}, state) do
    levels = case Application.get_env(:slack_logger_backend, :levels) do
      nil ->
        [:error] # by default only log error level messages
      levels ->
        levels
    end
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
    case System.get_env(@env_webhook) do
      nil ->
        Application.get_env(:slack_logger_backend, :slack)[:url]
      url ->
        url
    end
  end

  defp handle_event(level, message, [pid: _source_pid, module: module, function: function, file: file, line: line]) do
    {:ok, json} = JSON.encode(%{text: """
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

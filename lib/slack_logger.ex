defmodule SlackLogger do
  use GenEvent

  @env_webhook "SLACK_LOGGER_WEBHOOK_URL"

  @doc false
  def init(__MODULE__) do
    unless levels = Application.get_env(:slack_logger_backend, :levels) do
      levels = [:error] # by default only log error level messages
    end
    {:ok, %{levels: levels}}
  end

  @doc false
  def handle_call(_request, state) do
    {:ok, state}
  end

  @doc false
  def handle_event({level, _pid, {Logger, message, _timestamp, detail}}, %{levels: levels} = state) do
    handle_event(level, message, detail, levels)
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

  defp handle_event(level, message, detail, levels) do
    if level in levels do
      [pid: _source_pid, module: module, function: function, file: file, line: line] = detail
      {:ok, json} = Poison.encode(%{text: """
      An event has occurred: _#{message}_
      *Level*: #{level}
      *Module*: #{module}
      *Function*: #{function}
      *File*: #{file}
      *Line*: #{line}
      """})
      response =
        get_url
        |> HTTPoison.post(json)
    end
  end

end

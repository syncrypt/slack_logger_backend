ExUnit.start

defmodule SlackLoggerTest do
  use ExUnit.Case
  require Logger

  setup do
    bypass = Bypass.open
    Application.put_env :slack_logger_backend, :slack, [url: "http://localhost:#{bypass.port}/hook"]
    System.put_env "SLACK_LOGGER_WEBHOOK_URL", "http://localhost:#{bypass.port}/hook"
    {:ok, %{bypass: bypass}}
  end

  test "posts the error to the Slack incoming webhook", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/hook" == conn.request_path
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 200, "ok")
    end
    Logger.error "This error should be logged to Slack"
    :timer.sleep(200) # this is terrible but i need to wait for bypass
  end

  test "doesn't post a debug message to Slack if the level is not set" do
    Application.put_env :slack_logger_backend, :levels, [:info]
    Logger.error "This error should not be logged to Slack"
    :timer.sleep(200) # this is terrible but i need to wait for bypass
  end

end

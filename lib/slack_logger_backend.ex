defmodule SlackLoggerBackend do
  use Application
  require Logger

  def start(_, _) do
    Logger.add_backend(SlackLogger)
    {:ok, self}
  end

  def stop(_) do

  end

end

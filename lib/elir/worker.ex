defmodule Elir.Worker do
  @moduledoc """
  Worker responsible for starting and running a test suite
  """
  use GenServer

    # @suite_timeout Keyword.get(Application.get_env(:wall_test, WallTest.Brooklyn), :suite_timeout, 5_000)

    def start_link(data) do
      GenServer.start_link(__MODULE__, data, [])
    end

    def init(state) do
      {:ok, state}
    end

    def handle_call([command, val, target_dir, args, elir_config] = _data, _from, state) do
      result = Elir.TestSuiteRunner.run([command, target_dir, val, elir_config], args)
      {:reply, [result], state}
    end

    def run(pid, value) do
      GenServer.call(pid, value, :infinity)
    end
end

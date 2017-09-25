defmodule Elir.TestSuiteRunner do
  @moduledoc """
  Executes a full testsuite, or any other command available in the system
  """
  require Logger

  def run(data, args) do
    run_external_command(data, args)
  end

  defp run_external_command([cmd, target_dir, env_variables, elir_config] = _data, args) do
    Logger.info "==> Running #{cmd} #{target_dir}, with: #{inspect(env_variables)}, args: #{inspect(args)}"
    [command | rest] = String.split(cmd, " ")
    run_log_file = elir_config["log_file"] || false

    stream =
      if run_log_file do
        {:ok, pid} = Elir.FileStream.start_link(file: run_log_file)
        IO.stream(pid, :line)
      else
        IO.binstream(:standard_io, :line)
      end

    labels =
      Enum.reduce(env_variables, [], fn({l, _v}, acc) -> acc ++ [l] end)
      |> Enum.join(", ")

    {_, res} = executor(command, rest ++ args, [
                  stream: stream,
                  cd: target_dir,
                  env: env_variables ++ [{"labels", labels}],
                  parallelism: true
                ])

    if res > 0 do
      Logger.error "Shutting down; #{inspect res}"
      System.at_exit(fn _ -> exit({:shutdown, 1}) end)
    end
  end

  def executor(cmd, args, opts \\ []) do
    std_err = opts[:stderr_to_stdout] || true
    stream = opts[:stream] || IO.binstream(:standard_io, :line)
    opts = Keyword.drop(opts, [:into, :stderr_to_stdout, :stream])
    System.cmd(cmd, args, [into: stream, stderr_to_stdout: std_err] ++ opts)
  end

end

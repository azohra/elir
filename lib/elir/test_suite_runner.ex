defmodule Elir.TestSuiteRunner do
  @moduledoc """
  Executes a command available that can be found by the host system
  """
  require Logger

  alias Elir.Utils

  def run(data, args) do
    run_external_command(data, args)
  end

  defp run_external_command([cmd, target_dir, env_variables, elir_config] = _data, args) do
    Logger.info "==> Running #{cmd} #{target_dir}, with: #{args_details(env_variables, args)}"
    [command | rest] = String.split(cmd, " ")
    run_log_file = elir_config["log_file"] || false
    Logger.info inspect(elir_config)

    context_env_user_vars = Utils.user_vars(elir_config)
    {process_name, process_id} = Utils.process_name_and_id(elir_config["process"])

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
                  env: env_variables ++ [{"labels", labels}, {process_name, process_id}],
                  parallelism: true
                ])

    if res > 0 do
      Logger.error "Shutting down; #{inspect res}; #{args_details(env_variables, args)}"
      System.at_exit(fn _ -> exit({:shutdown, 1}) end)
    end
  end

  def executor(cmd, args, opts \\ []) do
    std_err = opts[:stderr_to_stdout] || true
    stream = opts[:stream] || IO.binstream(:standard_io, :line)
    opts = Keyword.drop(opts, [:into, :stderr_to_stdout, :stream])
    System.cmd(cmd, args, [into: stream, stderr_to_stdout: std_err] ++ opts)
  end

  defp args_details(env_variables, args) do
    " #{inspect(env_variables)}, args: #{inspect(args)}"
  end
end

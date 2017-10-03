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
    run_log_file = elir_config["log_file"] || false
    
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

      uber_cmd = interpolated_cmd(cmd, context_env_user_vars ++ env_variables)
      [command | rest] = String.split(uber_cmd, " ")

      Logger.info "[#{process_name}: #{process_id}] #{command} #{target_dir}, with: #{args_details(env_variables, args, context_env_user_vars)}"
      
      {_, res} = executor(command, rest ++ args, [
                  stream: stream,
                  cd: target_dir,
                  env: context_env_user_vars ++ env_variables ++ [{"labels", labels}, {process_name, process_id}],
                  parallelism: true
                ])

    Logger.info "[#{process_name}: #{process_id}] finished."
    if res > 0 do
      # Logger.info "[#{process_name}: #{process_id}] exits with #{inspect(res)}"
      System.at_exit(fn _ -> exit({:shutdown, 1}) end)
    end
  end

  def executor(cmd, args, opts \\ []) do
    std_err = opts[:stderr_to_stdout] || true
    stream = opts[:stream] || IO.binstream(:standard_io, :line)
    opts = Keyword.drop(opts, [:into, :stderr_to_stdout, :stream])
    System.cmd(cmd, args, [into: stream, stderr_to_stdout: std_err] ++ opts)
  end

  defp args_details(env_variables, args, context_env) do
    " #{inspect(env_variables)}, args: #{inspect(args)}, context_env: #{inspect(context_env)}"
  end

  defp interpolated_cmd(cmd, env) do
    command = String.replace(cmd, "$", "#")
    ctx = Enum.reduce(env, %{}, fn({l, v}, acc) -> Map.put(acc, :"#{l}", v) end)
    {rez, _env} = Code.eval_string("\"#{command}\"", ["elir": ctx])
    
    rez
  end
end

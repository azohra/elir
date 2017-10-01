defmodule Elir do
  @moduledoc """
  Documentation for Elir.
  """
  @config_file_name "elir.yml"
  
  require Logger

  @doc """
  CLI main entry point
  """
  def main([]), do: main(["", nil])
  def main(argv) do
    [test_folder | args] = argv
    {:ok, config} = configure(test_folder)

    Elir.Application.start(__MODULE__, [%{folder: test_folder, args: args, config: config}])
    
    run_suite = fn cmd, val ->
      Task.async(fn -> pool_run([cmd, val, test_folder, args, config["elir"]]) end)
    end

    config["elir"]["env"]
    |> Elir.Utils.cartesian(Map.get(config["elir"], "inflector", true))
    |> Enum.map(&(run_suite.(config["elir"]["cmd"], &1)))
    |> Enum.map(&(Task.await(&1, Elir.Application.suite_timeout(config["elir"]))))

  end

  def configure(path \\ [])
  def configure([]), do: {:error, "must supply the parameters"}
  def configure(path) do
    config_file_path = define_path("#{path}/#{Elir.config_file_name}")

    if File.exists?(config_file_path) do
      {:ok, YamlElixir.read_from_file(config_file_path)}
    else
      Logger.error("missing the configuration parameters.")
      exit(:shutdown)
    end
  end

  def config_file_name, do: @config_file_name
  
  defp define_path(path) do
    if File.exists?(path) do
      path
    else
      Path.join(File.cwd!, path)
    end
  end

  defp pool_run(data) do
    :poolboy.transaction(
      Elir.Application.pool_name(),
      fn(pid) ->
        Elir.Worker.run(pid, data)
      end,
      :infinity
    )
  end
end

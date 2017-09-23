defmodule Elir do
  @moduledoc """
  Documentation for Elir.
  """

  @app_conf Application.get_env(:elir, Elir)
  @config_file_name "elir.yml"

  require Logger

  alias Elir.Utils

  @doc """
  Florin's dev notes:

  the params are expected to be:
  [specs_folder | [whatever follows after, after, after, after, ...]]
  """
  def start_suite(params) do
    [test_folder | args] = params
    {:ok, config} = Elir.configure(test_folder)

    run_suite = fn cmd, val ->
      Task.async(fn -> pool_run([cmd, val, test_folder, args, config["elir"]]) end)
    end

    config["elir"]["env"]
    |> Utils.cartesian
    |> Enum.map(&(run_suite.(config["elir"]["cmd"], &1)))
    |> Enum.map(&(Task.await(&1, suite_timeout())))
  end

  def main(args) do
    Logger.info("Elir v0.1.15")
    Application.ensure_all_started(:elir)
    Elir.start_suite(args)
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

  def config_file_name, do: @config_file_name

  def configure(path \\ nil)
  def configure(nil), do: %{}
  def configure(path) do
    config_file_path = define_path("#{path}/#{Elir.config_file_name}")

    if File.exists?(config_file_path) do
      {:ok, YamlElixir.read_from_file(config_file_path)}
    else
      {:error, "config file not found"}
    end

  end

  def pool_attributes do
    %{pool_size: pool_size(), max_overflow: max_overflow()}
  end

  def pool_size do
    @app_conf |> Keyword.get(:pool_size, 10)
  end

  def max_overflow do
    @app_conf |> Keyword.get(:max_overflow, 0)
  end

  def suite_timeout do
    @app_conf |> Keyword.get(:suite_timeout, 1_500)
  end

  defp define_path(path) do
    if !File.exists?(path) do
      File.cwd!
      |> Path.join(path)
    else
      path
    end
  end
end

defmodule Mix.Tasks.Exec do
  @moduledoc """
    task to run all the suites in parallel.

    $ mix exec <folder containing the config file for the Elir runner>
  
    Example:  
    $ mix exec rspec_demo
  """
  require Logger

  use Mix.Task

  @doc false
  def run(args) do
    Application.ensure_all_started(:elir)
    Elir.main(args)
  end
end

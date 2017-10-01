defmodule Elir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  
  require Logger

  def start(_type, [%{folder: folder, args: args, config: config}] = opts) do
    # List all child processes to be supervised
    # Logger.warn("#{__MODULE__}.start/2; opts: #{inspect(opts)}")
    
    poolboy_config = [
      {:name, {:local, pool_name()}},
      {:worker_module, Elir.Worker},
      {:size, pool_size(config["elir"])},
      {:max_overflow, max_overflow(config["elir"])}
    ]

    children = [
      # Starts a worker by calling: Elir.Worker.start_link(arg)
      # {Elir.Worker, arg},
      {Elir.ConfigAgent, args[:config]},
      :poolboy.child_spec(pool_name(), poolboy_config, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Elir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def pool_name do
    :elir_pool
  end

  def pool_size(config) do
    config |> Map.get("pool_size", 1)
  end

  def max_overflow(config) do
    config |> Map.get("max_overflow", 0)
  end

  def suite_timeout(config) do
    config |> Map.get("suite_timeout", :infinity)
  end
end

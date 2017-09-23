defmodule Elir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    import Supervisor.Spec, warn: false

    poolboy_config = [
      {:name, {:local, pool_name()}},
      {:worker_module, Elir.Worker},
      {:size, Elir.pool_size()},
      {:max_overflow, Elir.max_overflow()}
    ]

    # Define workers and child supervisors to be supervised
    children = [
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
end

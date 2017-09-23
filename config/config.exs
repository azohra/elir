# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger, level: :info

config :elir, Elir,
  suite_timeout: :infinity,
  pool_size: 20,
  max_overflow: 5

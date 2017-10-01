defmodule Elir.ConfigAgent do 
  @moduledoc """
  store the config
  """
  use Agent

  def start_link(config) do
    Agent.start_link(fn -> %{config: config} end, name: __MODULE__)
  end

  def get_config(pid) do 
    Agent.get(pid, fn map -> map[:config] end)
  end
  
end
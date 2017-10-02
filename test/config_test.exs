defmodule ConfigTest do
  use ExUnit.Case
  
  @fixtures "#{Path.expand(".", __DIR__)}/fixtures"
  @config_file "#{Path.expand(".", __DIR__)}/fixtures/elir.yml"

  test "can find the test Elir config file" do
    assert File.exists? @config_file
  end

  test "elir can parse the config into a proper structures" do
    {:ok, config} = Elir.configure(@fixtures)
    assert %{"devices" => ["mobile", "desktop"],
    "languages" => ["fr", "en"], "servers" => ["local"]} = config["elir"]["env"]
  end

  test "context vars are parsable" do
    {:ok, config} = Elir.configure(@fixtures)
    assert [{"alpha", "beta"}, {"gamma", "delta"}]
      = Elir.Utils.user_vars(config["elir"])
  end
end
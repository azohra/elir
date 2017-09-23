defmodule ElirTest do
  use ExUnit.Case
  
  @elir_demo_project_path "rspec_demo"
  @env [%{"devices" => "desktop, mobile"}, %{"languages" => "en, babylonian"}]

  test "Elir can be configured from a YAML file in a relative path" do
    assert {:ok, file} = Elir.configure(@elir_demo_project_path)
    assert %{"elir" => %{"env" => _env, "cmd" => _cmd}} = file
  end

  test "Elir can be configured from a YAML file given in a fully specified path" do
    fqp = File.cwd! |> Path.join(@elir_demo_project_path)
    
    assert {:ok, file} = Elir.configure(fqp)
    assert %{"elir" => %{"env" => _env, "cmd" => _cmd}} = file
  end

  test "poor-man cartesian values" do
    assert [
      [{"device", "desktop"}, {"language", "en"}], 
      [{"device", "desktop"}, {"language", "babylonian"}], 
      [{"device", "mobile"}, {"language", "en"}], 
      [{"device", "mobile"}, {"language", "babylonian"}]
    ] == Elir.Utils.cartesian(@env)
  end
end

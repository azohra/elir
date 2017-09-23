defmodule Elir.Utils do
  @moduledoc """
  various utilitarian functions
  """
  
  @doc """
  I am cheating here ... sorry.

  return the cartesian product between every value of the k/V structures in the given list.
  The list contain maps with a singular key ... (the weird result of getting a yaml converted to Elixir)
  """
  def cartesian(list_w_maps) do
    pop_one = fn map, keys ->
      k = List.first(keys)
      [k, map[k]]
    end
    
    keys = 
      list_w_maps
      |> Enum.map(&(pop_one.(&1, Map.keys(&1))))
      
    for_this = 
      keys
      |> List.foldl([], fn([k, v], acc) -> acc ++ ["#{k} <- ~w{#{String.replace(v, ~r/\W+/, " ")}}"] end)
      |> Enum.join(",")
    
    do_this = 
      keys
      |> List.foldl([], fn([k, _v], acc) -> acc ++ ["{\"#{Inflectorex.singularize(k)}\", #{k}}"] end)
      |> Enum.join(",")
    
      {cartesian, _binding} = Code.eval_string("for #{for_this}, into: [] do; [#{do_this}]; end")
      cartesian
  end
end
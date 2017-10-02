defmodule Elir.Utils do
  @moduledoc """
  various utilitarian functions
  """

  @doc """
  I am cheating here ... sorry.

  return the cartesian product between every value of the k/V structures in the given list.
  The list contain maps with a singular key ... (the weird result of getting a yaml converted to Elixir)
  """
  def cartesian(env_map, depluralize \\ false) do

    keys =
      env_map
      |> Map.keys
      
    for_this =
      keys
      |> List.foldl([], fn(k, acc) -> acc ++ ["#{String.downcase(k)} <- ~w{#{Enum.join(env_map[k], " ")}}"] end)
      |> Enum.join(", ")

    do_this =
      keys
      |> List.foldl([], fn(k, acc) -> acc ++ ["{\"#{singularize(k, depluralize)}\", #{String.downcase(k)}}"] end)
      |> Enum.join(",")
      
      {cartesian, _binding} = Code.eval_string("for #{for_this}, into: [] do; [#{do_this}]; end")
      cartesian
  end

  def user_vars(elir_config), do: map_from_list_of_maps(elir_config["context_env"])
  
  def process_name_and_id(nil), do: process_name_and_id(%{})  
  def process_name_and_id(elir_config) do    
    process_name = Map.get(elir_config, "name", "PROCESS_ID")
    
    length = Map.get(elir_config, "length", 10)
    prefix = Map.get(elir_config, "prefix", "")
    suffix = Map.get(elir_config, "suffix", "")
    sep    = Map.get(elir_config, "sep", "")
    
    process_id = 
      [prefix, String.upcase(SecureRandom.hex(length)), suffix]
      |> Enum.join(sep)

    {process_name, process_id}  
  end

  defp singularize(plural, false), do: plural
  defp singularize(plural, true), do: Inflectorex.singularize(plural)

  defp map_from_list_of_maps(nil), do: []
  defp map_from_list_of_maps(list_of_maps) do
    list_of_maps
    |> Map.to_list
  end
end

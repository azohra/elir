defmodule Elir.Utils do
  @moduledoc """
  various utilitarian functions
  """

  @doc """
  I am cheating here ... sorry.

  return the cartesian product between every value of the k/V structures in the given list.
  The list contain maps with a singular key ... (the weird result of getting a yaml converted to Elixir)
  """
  def cartesian(list_w_maps, depluralize \\ false) do
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
      |> List.foldl([], fn([k, _v], acc) -> acc ++ ["{\"#{singularize(k, depluralize)}\", #{k}}"] end)
      |> Enum.join(",")

      {cartesian, _binding} = Code.eval_string("for #{for_this}, into: [] do; [#{do_this}]; end")
      cartesian
  end

  def user_vars(elir_config), do: map_from_list_of_maps(elir_config["context_env"])
  
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

  defp map_from_list_of_maps(list_of_maps) do
    list_of_maps
    |> Enum.reduce(%{}, fn(m, acc) -> Map.merge(acc, m) end)
    |> Map.to_list
  end
end

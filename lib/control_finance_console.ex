defmodule ControlFinanceConsole do
  def compound(principal, limit \\ 50000, counter \\ 0, cumulative_total \\ 0.0) do
    principal = principal * 1.0
    interest = case principal do
      p when p < 300 -> 0.01
      p when p < 1000 -> 0.011
      p when p < 4500 -> 0.0125
      p when p < 10000 -> 0.014
      _ -> 0.015
    end

    profit = principal * interest
    total = profit + principal
    IO.puts "#{ counter + 1},#{ format(principal) },#{format(profit)},#{interest},#{format(cumulative_total)}"
    
    if total < limit do
      compound(total, limit, counter+1, profit + cumulative_total)
    end
  end

  defp format(number) do
    number
    |> :erlang.float_to_binary(decimals: 2)
  end
end

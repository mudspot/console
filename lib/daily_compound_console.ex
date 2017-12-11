defmodule DailyCompoundConsole do
  def compound(principal, interest, term, months, counter \\ 0) do
    if (counter < months) do
      profit = principal * interest/100.0 * term
      total = profit + principal
      IO.puts "#{ counter + 1} #{ format(total) } #{format(profit)} #{format(principal*1.0)}"
      compound(total + 0, interest, term, months, counter+1)
    end
  end

  def daily_compound(principal, interest, days, accrue_limit \\ 10, accrue \\ 0, counter \\ 0) do
    if (counter < days) do
      profit = principal * interest/100.0
      check_accrue = accrue + profit
      %{principal: new_principal, accrue: new_accrue} = if (check_accrue <= accrue_limit) do
        %{principal: principal, accrue: check_accrue}
      else
        n_principal = principal + check_accrue
        %{principal: n_principal, accrue: 0}
      end
      # total = profit + principal
      IO.puts "#{ counter + 1}  #{format(principal*1.0)} #{format(profit)} #{format(profit*30)} #{format(profit*365)} #{format(new_accrue*1.0)}"
      
      daily_compound(new_principal, interest, days, accrue_limit, new_accrue, counter + 1)
    end  
  end

  defp format(number) do
    number
    |> :erlang.float_to_binary(decimals: 2)
  end
end
defmodule Console do
  import SweetXml

  @moduledoc """
  Documentation for Console.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Console.hello
      :world

  """
  def hello do
    :world
  end

  def test do
    val = "<document><tr><td><span>" <> "</span></td><td class=\"Ta(end) Fw(b) Lh(14px)\" data-test=\"PREV_CLOSE-value\" data-reactid=\"41\"><span class=\"Trsdu(0.3s) \" data-reactid=\"42\">2,493.766</span></td></tr><tr class=\"Bxz(bb) Bdbw(1px) Bdbs(s) Bdc($lightGray) H(36px) \" data-reactid=\"43\"><td class=\"C(black) W(51%)\" data-reactid=\"44\"><span data-reactid=\"45\">" <> "</span></td></tr></document>"
    
    val 
    |> xpath(~x"//document/tr/td/span[@data-reactid=\"42\"]/text()"s)
    |> String.replace(",","")   
  end

  def get_quote(symbol) do
    site = "https://finance.yahoo.com/quote/#{symbol}"
    {:ok, %{body: response_body}} = HTTPoison.get(site)
    
    raw_cut = response_body 
    |> String.split("Previous Close", parts: 2, trim: true)
    |> Enum.at(1)
    
    case raw_cut do
      nil -> false
      _ ->
        raw_cut
        |> String.split("Open", parts: 2, trim: true)
        |> Enum.at(0)
        |> parseQuote
    end
    #|> Enum.take(3)
    #|> List.pop_at(-1)

    #{raw_quote, _} = raw_cut 
    #|> String.splitter(["{", "}"]) 
    #|> Enum.take(4)
    #|> List.pop_at(1)

    #IO.inspect raw_cut
    #IO.inspect raw_quote
    #{:ok, %{raw: quote}} = Poison.Parser.parse("{#{raw_quote}}", keys: :atoms)

    #quote
  end

  defp parseQuote(data) do
    val = "<document><tr><td><span>" <> data <> "</span></td></tr></document>"
    
    val 
    |> xpath(~x"//document/tr/td/span[@data-reactid=\"42\"]/text()"s)
    |> String.replace(",","")   
  end
end

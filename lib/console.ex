defmodule Console do
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

  def get_quote(symbol) do
    site = "https://finance.yahoo.com/quote/#{symbol}"
    {:ok, %{body: response_body}} = HTTPoison.get(site)
    {raw_cut, _} = response_body 
    |> String.splitter(["previousClose", "regularMarketOpen"], trim: true)
    |> Enum.take(3)
    |> List.pop_at(-1)

    {raw_quote, _} = raw_cut 
    |> String.splitter(["{", "}"]) 
    |> Enum.take(4)
    |> List.pop_at(1)

    {:ok, %{raw: quote}} = Poison.Parser.parse("{#{raw_quote}}", keys: :atoms)

    quote
  end
end

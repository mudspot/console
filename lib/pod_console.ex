defmodule PodConsole do
  def deregister(to_delete) do
    %{
      headers: headers,
      url: url,
      domain: domain
    } = staging_env()
        
    to_delete
    |> String.split(",", trim: true)
    |> Enum.each(&do_deregister(&1, domain, url, headers))
  end

  defp do_deregister(pod_id, domain, url, headers) do
    {:ok, json} = %{
      pod_id: "#{pod_id}.#{domain}"
    }
    |> Poison.encode

    IO.inspect json
    IO.inspect headers
    IO.inspect url
    request = HTTPoison.post url, json, headers, [recv_timeout: 30000]
    IO.inspect request
  end

  defp staging_env() do
    headers = [
      "Accept": "application/json; Charset=utf-8",
      "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJwb2RzZW5zZSJ9.nR-BfzBXpp60wwqAZ2HAxcL6qmYv8oZYRaqjhfQxsN_Zf64KoBztvQ4mjJZ65ihautQ9VjoCUrxyBLnLjH0GRQ"
    ]

    url = "https://podregistry.nogginhat.me/pod/deregister"
    domain = "nogginhat.me"

    %{
      headers: headers,
      url: url,
      domain: domain
    }
  end
end
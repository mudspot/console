defmodule MillinerConsole do
    def loadtest_sustain() do
        ["a", "b", "c", "d"]
        |> Enum.each(fn(i) ->            
            spawn fn ->
                MillinerConsole.loadtest("namaste#{i}", 250)
            end
        end)
    end

    def loadtest(name, loop) do
        for i <- 1..loop do
            #spawn fn ->
                MillinerConsole.loadtest_impl("#{name}#{i}", "NamesteFN", "NamesteLN", "#{name}#{i}@nogginasia.com", "fortytwo")
            #end
            :timer.sleep(Enum.random(4000..8000))        
        end
    end

    def loadtest_impl(hat, userName, userLastName, userEmail, userPassword) do
        a = DateTime.utc_now |> DateTime.to_unix
        response = signup(hat, userName, userLastName, userEmail, userPassword)
        b = DateTime.utc_now |> DateTime.to_unix
        %{ c: c, status: status} = if response=="OK" do
            create_response = create(hat)
            end_create = DateTime.utc_now |> DateTime.to_unix
            final_status = if create_response=="OK" do
                "DONE"
            else
                "FAIL"
            end
            %{ c: end_create, status: final_status}
        end

        result = %{
            hat: hat,
            status: status,
            signup: b - a,
            create: c - b,
            total: c - a
        }

        { :ok, body} = result
        |> Poison.encode

        IO.inspect body
    end

    def signup(hat, userName, userLastName, userEmail, userPassword) do
        { :ok, body} = %{
            fullName: "#{userName} #{userLastName}",
            username: "#{hat}",
            email: "#{userEmail}",
            pass: "#{userPassword}",
            passRepeat: "#{userPassword}"
        }
        |> Poison.encode

        %{ cluster: cluster, secret: access_token} = cluster_config()

        case HTTPoison.post("https://#{cluster}/api/signup", body, headers(access_token), options()) do
            {:ok, %{status_code: 200, body: response_body}} ->
                {:ok, %{message: message, status: status}} = Poison.Parser.parse(response_body, keys: :atoms)
                #IO.inspect message
                status
            {:ok, %{status_code: 400, body: response_body}} ->
                {:ok, %{message: message, cause: cause}} = Poison.Parser.parse(response_body, keys: :atoms)
                #IO.inspect message
                #IO.inspect cause
                "Fail"
            true ->
                "Error"
        end
    end

    def create(hat) do
        %{ cluster: cluster, secret: access_token} = cluster_config()
        
        case HTTPoison.get("https://#{cluster}/api/manage/hat/create/#{hat}.#{cluster}", headers(access_token), options()) do
            {:ok, %{status_code: 200, body: response_body}} ->
                {:ok, %{message: message, status: status}} = Poison.Parser.parse(response_body, keys: :atoms)
                #IO.inspect message
                #IO.inspect "#{hat} created"
                status
            {:ok, %{status_code: 400, body: response_body}} ->
                {:ok, %{message: message, cause: cause, details: details}} = Poison.Parser.parse(response_body, keys: :atoms)
                #IO.inspect message
                #IO.inspect cause
                #IO.inspect details
                "Fail"
            true ->
                "Error"
        end            
    end

    defp cluster_config() do
        noggin_cluster_config()
    end

    defp hubat_cluster_config() do
        %{
            cluster: "hubat.net",
            secret: "sd3_i*w7dv-#eobog)vr*iw%ht@7fw(=dc=uv4=m3bzq69sf_9"
        }
    end

    defp noggin_cluster_config() do
        %{
            cluster: "noggin.hubat.net",
            secret: "sd3_i*w7dv-#eobog)vr*iw%ht@7fw(=dc=uv4=m3bzq69sf_9"
        }
    end

    defp mock_cluster_config() do
        %{
            cluster: "skeleta.ext:4000",
            secret: "sd3_i*w7dv-#eobog)vr*iw%ht@7fw(=dc=uv4=m3bzq69sf_9"
        }
    end

    defp headers(access_token) do
        [
            "Content-Type": "application/json;",
            "X-Auth-Token": access_token
        ]
    end

    defp options() do
        [ timeout: 300000, recv_timeout: 300000]
    end

end
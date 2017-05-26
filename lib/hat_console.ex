defmodule HatConsole do
    def login(hat_id, username, password) do
        headers = [
            "Accept": "application/json; Charset=utf-8",
            "username": username,
            "password": password
        ]

        case HTTPoison.get("https://#{hat_id}/users/access_token", headers) do
            {:ok, %{status_code: 200, body: response_body}} ->
                {:ok, response} = Poison.Parser.parse(response_body, keys: :atoms)
                case response do
                    %{error: error, message: _message} ->
                        error
                    %{accessToken: accessToken, userId: _userId} ->
                        accessToken
                end
            true ->
                "Error"
        end
    end

    def validate_token(access_token, hatid \\ nil) do
        hat_id = if hatid==nil do
            hatid_from_token access_token
        else
            hatid
        end

        case HTTPoison.get("https://#{hat_id}/publickey") do
            {:ok, %{body: public_key}} ->
                pkey = JsonWebToken.Algorithm.RsaUtil.public_key public_key
                opts = %{ alg: "RS256", key: pkey}
                case JsonWebToken.verify access_token, opts do
                    {:ok, claims} ->
                        claims
                    {:error, message} ->
                        message
                end
            true ->
                "Error"
        end
    end

    def save_profile(access_token, profile) do
        {:ok, json} = Poison.encode %{profile: profile}

        hat_id = hatid_from_token access_token

        HTTPoison.post "https://#{hat_id}/api/v2/data/hat/profile", json, headers(access_token)
    end

    def get_profile(access_token) do
        hat_id = hatid_from_token access_token
        request = HTTPoison.get "https://#{hat_id}/api/v2/data/hat/profile", headers(access_token)

        case request do
            {:ok, %{status_code: 200, body: response_body}} ->
                {:ok, response} = Poison.Parser.parse(response_body, keys: :atoms)
                case response do
                    %{error: error, message: _message} ->
                        error
                    [%{data: profile, recordId: recordId}] ->
                        profile
                        |> Map.put(:recordId, recordId)
                end
            true ->
                "Error"
        end
    end

    def delete_profile(access_token, record_id) do
        hat_id = hatid_from_token access_token
        request = HTTPoison.delete "https://#{hat_id}/api/v2/data?records=#{record_id}", headers(access_token)

        case request do
            {:ok, %{status_code: 200, body: response_body}} ->
                response_body
            true ->
                "Error"
        end
    end

    defp headers(access_token) do
        [
            "Content-Type": "application/json;",
            "X-Auth-Token": access_token
        ]
    end

    defp hatid_from_token(access_token) do
        {:ok, jwt_token} = access_token
        |> String.split(".")
        |> Enum.at(1)
        |> Base.decode64(padding: false)

        { :ok, token_parts} = Poison.Parser.parse jwt_token, keys: :atoms
        token_parts[:iss]
    end
end
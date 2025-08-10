defmodule ElixirPlayground.Airtable do
  @base_id "appCmysegOYgrUMsE"
  @table_name "tblILZeZPnCFsgxd4"
  @api_key System.get_env("AIRTABLE_API_KEY")
  @url "https://api.airtable.com/v0/#{@base_id}/#{@table_name}"

  def list_records do
    headers = [
      {"Authorization", "Bearer #{@api_key}"},
      {"Content-Type", "application/json"}
    ]

    request = Finch.build(:get, @url, headers)

    case Finch.request(request, ElixirPlayground.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        Jason.decode!(body)

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, %{status: status, body: Jason.decode!(body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

defmodule ElixirPlayground.Airtable do
  @base_id "appCmysegOYgrUMsE"
  @table_name "tblILZeZPnCFsgxd4"
  @url "https://api.airtable.com/v0/#{@base_id}/#{@table_name}"

  @default_page_size 100

  def list_records(opts \\ []) do
    api_key = Application.get_env(:elixir_playground, :airtable)[:api_key]

    IO.inspect(api_key)

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    offset = Keyword.get(opts, :offset, nil)
    page_size = Keyword.get(opts, :page_size, @default_page_size)

    url = build_url(@url, offset: offset, page_size: page_size)
    IO.puts("Requesting Airtable API: #{url}")
    request = Finch.build(:get, url, headers)

    case Finch.request(request, ElixirPlayground.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        Jason.decode!(body)

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, %{status: status, body: Jason.decode!(body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_url(base, opts) do
    query_p =
      [
        {"pageSize", opts[:page_size]},
        {"offset", opts[:offset]}
      ]
      |> Enum.filter(fn {_key, value} -> not is_nil(value) end)
      |> Enum.map(fn {key, value} -> {key, to_string(value)} end)

    case query_p do
      [] -> base
      params -> base <> "?" <> URI.encode_query(params)
    end
  end
end

defmodule ElixirPlayground.Airtable do
  @default_page_size 100

  def list_records(opts \\ []) do
    config = Application.get_env(:elixir_playground, :airtable)
    base_id = config[:base_id]
    table_name = config[:table_name]
    api_key = config[:api_key]

    base_url = "https://api.airtable.com/v0/#{base_id}/#{table_name}"
    IO.inspect(api_key)

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    offset = Keyword.get(opts, :offset, nil)
    page_size = Keyword.get(opts, :page_size, @default_page_size)

    url = build_url(base_url, offset: offset, page_size: page_size)
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

  def get_record(record_id) do
    config = Application.get_env(:elixir_playground, :airtable)
    base_id = config[:base_id]
    table_name = config[:table_name]
    api_key = config[:api_key]

    url = "https://api.airtable.com/v0/#{base_id}/#{table_name}/#{record_id}"
    headers = build_headers(api_key)

    IO.puts("Getting record from Airtable: #{url}")
    request = Finch.build(:get, url, headers)

    case Finch.request(request, ElixirPlayground.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Finch.Response{status: 404, body: _body}} ->
        {:error, :not_found}

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, %{status: status, body: Jason.decode!(body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def update_record(record_id, fields) do
    config = Application.get_env(:elixir_playground, :airtable)
    base_id = config[:base_id]
    table_name = config[:table_name]
    api_key = config[:api_key]

    url = "https://api.airtable.com/v0/#{base_id}/#{table_name}/#{record_id}"
    headers = build_headers(api_key)

    body =
      %{
        "fields" => fields
      }
      |> Jason.encode!()

    IO.puts("Updating record in Airtable: #{url}")
    request = Finch.build(:patch, url, headers, body)

    case Finch.request(request, ElixirPlayground.Finch) do
      {:ok, %Finch.Response{status: 200, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}

      {:ok, %Finch.Response{status: 404, body: _body}} ->
        {:error, :not_found}

      {:ok, %Finch.Response{status: 422, body: response_body}} ->
        {:error, %{status: 422, type: :validation_error, body: Jason.decode!(response_body)}}

      {:ok, %Finch.Response{status: status, body: response_body}} ->
        {:error, %{status: status, body: Jason.decode!(response_body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def delete_record(record_id) do
    config = Application.get_env(:elixir_playground, :airtable)
    base_id = config[:base_id]
    table_name = config[:table_name]
    api_key = config[:api_key]

    url = "https://api.airtable.com/v0/#{base_id}/#{table_name}/#{record_id}"
    headers = build_headers(api_key)

    IO.puts("Deleting record from Airtable: #{url}")
    request = Finch.build(:delete, url, headers)

    case Finch.request(request, ElixirPlayground.Finch) do
      {:ok, %Finch.Response{status: 200, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}

      {:ok, %Finch.Response{status: 404, body: _body}} ->
        {:error, :not_found}

      {:ok, %Finch.Response{status: status, body: response_body}} ->
        {:error, %{status: status, body: Jason.decode!(response_body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Bonus: Create a new record
  def create_record(fields) do
    config = Application.get_env(:elixir_playground, :airtable)
    base_id = config[:base_id]
    table_name = config[:table_name]
    api_key = config[:api_key]

    url = "https://api.airtable.com/v0/#{base_id}/#{table_name}"
    headers = build_headers(api_key)

    body =
      %{
        "fields" => fields
      }
      |> Jason.encode!()

    IO.puts("Creating record in Airtable: #{url}")
    request = Finch.build(:post, url, headers, body)

    case Finch.request(request, ElixirPlayground.Finch) do
      {:ok, %Finch.Response{status: 200, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}

      {:ok, %Finch.Response{status: 422, body: response_body}} ->
        {:error, %{status: 422, type: :validation_error, body: Jason.decode!(response_body)}}

      {:ok, %Finch.Response{status: status, body: response_body}} ->
        {:error, %{status: status, body: Jason.decode!(response_body)}}

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

  defp build_headers(api_key) do
    [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]
  end
end

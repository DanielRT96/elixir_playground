defmodule ElixirPlaygroundWeb.AirtableLive do
  use ElixirPlaygroundWeb, :live_view
  alias ElixirPlayground.Airtable

  require Logger

  @page_size 100

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      IO.puts("connected")

      socket =
        socket
        |> assign(current_page: 1)
        |> load_page(nil, [])

      {:ok, socket}
    else
      IO.puts("Not connected")

      {:ok,
       assign(socket,
         records: [],
         columns: [],
         next_offset: nil,
         prev_offsets: [],
         current_page: 1
       )}
    end
  end

  @impl true
  def handle_event(
        "next",
        _params,
        %{assigns: %{next_offset: next, prev_offsets: prevs, current_page: page}} = socket
      ) do
    socket =
      socket
      |> assign(current_page: page + 1)
      |> load_page(next, [next | prevs])

    {:noreply, socket}
  end

  def handle_event(
        "prev",
        _params,
        %{assigns: %{prev_offsets: [_current | rest], current_page: page}} = socket
      ) do
    prev_offset = List.first(rest)

    socket =
      socket
      |> assign(current_page: page - 1)
      |> load_page(prev_offset, rest)

    {:noreply, socket}
  end

  defp load_page(socket, offset, prev_stack) do
    case Airtable.list_records(offset: offset, page_size: @page_size) do
      %{"records" => records} = resp ->
        Logger.info("Loaded #{length(records)} records from Airtable",
          records: records,
          offset: offset
        )

        IO.inspect(records)

        next_offset = Map.get(resp, "offset")
        columns = infer_columns(records)

        assign(socket,
          records: records,
          columns: columns,
          next_offset: next_offset,
          prev_offsets: prev_stack
        )

      {:error, reason} ->
        IO.puts("ERROR loading Airtable records: #{inspect(reason)}")

        assign(socket,
          records: [],
          columns: [],
          next_offset: nil,
          prev_offsets: prev_stack
        )
        |> put_flash(:error, "Failed to load Airtable: #{inspect(reason)}")
    end
  end

  defp infer_columns([]), do: []

  defp infer_columns([%{"fields" => fields} | _]) when is_map(fields),
    do: fields |> Map.keys() |> Enum.sort()

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 p-6">
      <div class="max-w-full mx-auto">
        <!-- Header -->
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-gray-900 mb-2">Airtable Records</h1>
          <p class="text-gray-600">
            Viewing {length(@records)} record{if length(@records) != 1, do: "s"}
          </p>
        </div>
        
    <!-- Controls -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-4 mb-6">
          <.pagination
            has_prev={@prev_offsets != []}
            has_next={not is_nil(@next_offset)}
            current_page={@current_page}
            prev_event="prev"
            next_event="next"
            page_size={ElixirPlaygroundWeb.AirtableLive.page_size()}
            show_page_label={true}
            size="btn-md"
            prev_label="← Previous"
            next_label="Next →"
            class="w-full"
          />
        </div>
        
    <!-- Table -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              5
              <thead class="bg-gray-50">
                <tr>
                  <th
                    scope="col"
                    class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider sticky left-0 bg-gray-50 border-r border-gray-200"
                  >
                    ID
                  </th>
                  <%= for col <- @columns do %>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider whitespace-nowrap"
                    >
                      {col}
                    </th>
                  <% end %>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <%= for {rec, index} <- Enum.with_index(@records) do %>
                  <tr class={[
                    "hover:bg-blue-50 transition-colors",
                    if(rem(index, 2) == 0, do: "bg-white", else: "bg-gray-50")
                  ]}>
                    <td class={[
                      "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 sticky left-0",
                      if(rem(index, 2) == 0, do: "bg-white", else: "bg-gray-50"),
                      "border-r border-gray-200"
                    ]}>
                      <span class="text-xs bg-indigo-100 text-indigo-800 px-2 py-1 rounded">
                        {String.slice(rec["id"], 0..15)}
                      </span>
                    </td>
                    <%= for col <- @columns do %>
                      <td class="px-6 py-4 text-sm text-gray-900">
                        <div class="max-w-xs overflow-hidden">
                          {render_field_value(col, rec["fields"][col])}
                        </div>
                      </td>
                    <% end %>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>

        <%= if @records == [] do %>
          <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-12">
            <div class="text-center">
              <svg
                class="mx-auto h-12 w-12 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                >
                </path>
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">No records</h3>
              <p class="mt-1 text-sm text-gray-500">No data available to display.</p>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # New helper function for rendering field values with better formatting
  defp render_field_value("Státusz", value) do
    assigns = %{value: value}

    ~H"""
    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
      {@value}
    </span>
    """
  end

  defp render_field_value("NVF", true) do
    assigns = %{}

    ~H"""
    <span class="flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
      ✓ Yes
    </span>
    """
  end

  defp render_field_value("NVF", false) do
    assigns = %{}

    ~H"""
    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
      ✗ No
    </span>
    """
  end

  defp render_field_value(_col, value) when is_list(value) do
    assigns = %{items: format_list_for_display(value)}

    ~H"""
    <div class="flex flex-wrap gap-1">
      <%= for item <- @items do %>
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
          {item}
        </span>
      <% end %>
    </div>
    """
  end

  defp render_field_value(_col, value) do
    assigns = %{value: display(value)}

    ~H"""
    <span class="text-gray-900">{@value}</span>
    """
  end

  defp format_list_for_display(list) do
    Enum.map(list, fn
      %{"name" => name} -> name
      item when is_binary(item) -> item
      item -> to_string(item)
    end)
  end

  defp display(value) when is_list(value), do: format_list(value)
  defp display(value) when is_map(value), do: format_map(value)
  defp display(value), do: to_string(value || "")

  # Helper function to better format lists
  defp format_list(list) do
    list
    |> Enum.map(&format_list_item/1)
    |> Enum.join(", ")
  end

  defp format_list_item(item) when is_map(item) do
    # For objects in lists (like the "Ki foglalkozik vele?" field),
    # just show the name if available
    Map.get(item, "name", Jason.encode!(item))
  end

  defp format_list_item(item), do: to_string(item)

  # Helper function to better format maps
  defp format_map(map) do
    # For standalone maps, you might want to show specific fields
    # or fall back to JSON
    case Map.get(map, "name") do
      nil -> Jason.encode!(map)
      name -> name
    end
  end

  # Add a module attribute to define the page size constant
  def page_size, do: @page_size
end

defmodule ElixirPlaygroundWeb.LocationSelectorLive do
  use ElixirPlaygroundWeb, :live_view

  alias ElixirPlayground.Repo
  alias ElixirPlayground.Locations.Location

  @impl true
  def mount(_params, _session, socket) do
    locations = Repo.all(Location)

    {:ok,
     assign(socket,
       locations: locations,
       selected_location_id: nil
     )}
  end

  @impl true
  def handle_event("select_location", %{"location" => id}, socket) do
    IO.puts("Selected location ID: #{id}")
    {:noreply, assign(socket, selected_location_id: id)}
  end

  def handle_event("confirm_location", _params, socket) do
    {
      :noreply,
      socket
      |> put_flash(:info, "Location selected!")
      |> push_navigate(to: "/profile")
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4 max-w-md mx-auto">
      <h2 class="text-xl font-semibold mb-4">Select Your Location</h2>
      <form phx-change="select_location">
        <select
          name="location"
          id="location"
          class="select select-bordered w-full mb-4"
        >
          <option value="">-- Select location --</option>
          <%= for location <- @locations do %>
            <option value={location.id} selected={location.id == @selected_location_id}>
              {location.name}
            </option>
          <% end %>
        </select>
      </form>

      <button
        class={"btn btn-primary w-full #{if @selected_location_id, do: "", else: "btn-disabled"}"}
        phx-click="confirm_location"
        disabled={is_nil(@selected_location_id)}
      >
        Confirm
      </button>
    </div>
    """
  end
end

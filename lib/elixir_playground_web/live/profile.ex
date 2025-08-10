defmodule ElixirPlaygroundWeb.ProfileLive do
  use ElixirPlaygroundWeb, :live_view

  alias ElixirPlayground.Accounts
  alias ElixirPlayground.Locations

  def mount(%{"location_id" => location_id}, %{"user_token" => user_token} = _session, socket) do
    {user, _timestamp} = Accounts.get_user_by_session_token(user_token)

    location =
      case Locations.get_location(location_id) do
        nil -> nil
        location -> location
      end

    IO.inspect(user)
    {:ok, assign(socket, profile: user, location: location)}
  end

  def mount(_params, _session, socket) do
    {:ok, push_navigate(socket, to: ~p"/location-selector")}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6 bg-blue-50 text-black min-h-screen flex flex-col items-center">
      <h1 class="text-2xl font-bold mb-6">Welcome to your profile page!</h1>
      <p>Profile: {@profile.email}</p>
      <p>Role: {@profile.user_role}</p>
      <p>Location: {@location.name}</p>

      <button
        id="camera-btn"
        phx-hook="CameraPermission"
        class="btn btn-primary mt-4"
      >
        Take Photo
      </button>

      <video id="video" autoplay playsinline class="mt-4 hidden w-64 h-48 border"></video>
    </div>
    """
  end
end

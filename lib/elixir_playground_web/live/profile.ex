defmodule ElixirPlaygroundWeb.ProfileLive do
  use ElixirPlaygroundWeb, :live_view

  alias ElixirPlayground.Accounts

  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    {user, _timestamp} = Accounts.get_user_by_session_token(user_token)
    IO.inspect(user)
    {:ok, assign(socket, profile: user)}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6 bg-blue-50 text-black min-h-screen flex flex-col items-center">
      <h1 class="text-2xl font-bold mb-6">Welcome to your profile page!</h1>
      <p>Profile: {@profile.email}</p>
      <p>Role: {@profile.user_role}</p>
    </div>
    """
  end
end

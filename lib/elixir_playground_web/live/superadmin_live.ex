defmodule ElixirPlaygroundWeb.SuperadminLive do
  use ElixirPlaygroundWeb, :live_view
  alias ElixirPlayground.Accounts

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    {:ok, assign(socket, users: users)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 bg-gray-50 min-h-screen">
      <h1 class="text-2xl font-bold mb-6">Superadmin Dashboard</h1>

      <div class="overflow-x-auto bg-white shadow-md rounded-lg">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-100">
            <tr>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Email
              </th>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Role
              </th>
              <th
                scope="col"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Joined
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <%= for user <- @users do %>
              <tr class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {user.email}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm">
                  <span class={
                    case user.user_role do
                      :superadmin ->
                        "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-purple-100 text-purple-800"

                      :admin ->
                        "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800"

                      _ ->
                        "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800"
                    end
                  }>
                    {Atom.to_string(user.user_role) |> String.capitalize()}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {user.inserted_at |> Calendar.strftime("%Y-%m-%d %H:%M")}
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end

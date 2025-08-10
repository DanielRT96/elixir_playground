defmodule ElixirPlaygroundWeb.SuperadminLive do
  use ElixirPlaygroundWeb, :live_view
  alias ElixirPlayground.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_users(socket)}
  end

  @impl true
  def handle_event("change_role", %{"user_id" => user_id, "role" => role}, socket) do
    user = Accounts.get_user!(user_id)

    case Accounts.update_user_role(user, String.to_existing_atom(role)) do
      {:ok, _updated_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Role updated successfully.")
         |> load_users()}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to update role.")}
    end
  end

  defp load_users(socket) do
    assign(socket, users: Accounts.list_users())
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
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Email
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Role
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Joined
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <%= for user <- @users do %>
              <tr class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{user.email}</td>

                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  <form phx-change="change_role">
                    <input type="hidden" name="user_id" value={user.id} />
                    <select
                      name="role"
                      class="border-gray-300 rounded px-2 py-1 text-sm focus:ring-blue-500 focus:border-blue-500"
                      value={Atom.to_string(user.user_role)}
                    >
                      <option value="normal" selected={user.user_role == :normal}>Normal</option>
                      <option value="admin" selected={user.user_role == :admin}>Admin</option>
                      <option value="superadmin" selected={user.user_role == :superadmin}>
                        Superadmin
                      </option>
                    </select>
                  </form>
                </td>

                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {Calendar.strftime(user.inserted_at, "%Y-%m-%d %H:%M")}
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

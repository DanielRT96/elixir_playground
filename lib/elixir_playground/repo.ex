defmodule ElixirPlayground.Repo do
  use Ecto.Repo,
    otp_app: :elixir_playground,
    adapter: Ecto.Adapters.Postgres
end

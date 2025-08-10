defmodule ElixirPlayground.Locations do
  import Ecto.Query, warn: false

  alias ElixirPlayground.Repo
  alias ElixirPlayground.Locations.Location

  def get_location(id) do
    Repo.get(Location, id)
  end

  def list_locations do
    Repo.all(Location)
  end
end

defmodule ElixirPlaygroundWeb.PageController do
  use ElixirPlaygroundWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

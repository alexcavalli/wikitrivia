defmodule Wikitrivia.UserView do
  use Wikitrivia.Web, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Wikitrivia.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email
    }
  end
end

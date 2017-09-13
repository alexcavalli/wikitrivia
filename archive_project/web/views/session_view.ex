defmodule Wikitrivia.SessionView do
  use Wikitrivia.Web, :view

  def render("show.json", %{session: session}) do
    %{data: render_one(session, Wikitrivia.SessionView, "session.json")}
  end

  def render("session.json", %{session: session}) do
    %{
      token: session.token
    }
  end

  def render("error.json", _) do
    %{errors: "authentication failure"}
  end
end

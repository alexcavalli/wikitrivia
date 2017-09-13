defmodule Wikitrivia.ErrorView do
  use Wikitrivia.Web, :view

  def render("404.json", _assigns) do
    %{errors: "Page not found"}
  end

  def render("500.json", _assigns) do
    %{errors: "Server internal error"}
  end

  def render("auth_error.json", _assigns) do
    %{errors: "Authentication missing or invalid"}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end
end

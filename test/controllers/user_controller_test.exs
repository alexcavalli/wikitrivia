defmodule Wikitrivia.UserControllerTest do
  use Wikitrivia.ConnCase

  alias Wikitrivia.User
  @valid_attrs %{email: "example@example.com", password: "password"}
  @invalid_attrs %{}

  test "POST with valid attributes creates and renders user resource", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), user: @valid_attrs)
    response_body = json_response(conn, 201)
    assert response_body["data"]["id"]
    assert response_body["data"]["email"]
    refute response_body["data"]["password"]
    assert Repo.get_by(User, email: "example@example.com")
  end

  test "POST with invalid attributes doesn't create entity and renders error response", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
    response_body = json_response(conn, 422)
    assert response_body["errors"] != %{}
  end
end

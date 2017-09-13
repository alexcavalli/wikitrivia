defmodule Wikitrivia.SessionControllerTest do
  use Wikitrivia.ConnCase

  alias Wikitrivia.Session
  alias Wikitrivia.User
  @valid_attrs %{email: "example@example.com", password: "password"}

  setup %{conn: conn} do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    Repo.insert(changeset)
    {:ok, conn: conn}
  end

  test "POST with valid login attributes generates a session with token", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), user: @valid_attrs)
    response_body = json_response(conn, 201)
    token = response_body["data"]["token"]
    assert token
    session = Repo.get_by(Session, token: token)
    assert session
    assert session.user_id == Repo.get_by(User, email: "example@example.com").id
  end

  test "POST with invalid email doesn't create entity and renders error response", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), user: Map.put(@valid_attrs, :email, ""))
    response_body = json_response(conn, 401)
    assert response_body["errors"] != %{}
  end

  test "POST with invalid password doesn't create entity and renders error response", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), user: Map.put(@valid_attrs, :password, ""))
    response_body = json_response(conn, 401)
    assert response_body["errors"] != %{}
  end
end

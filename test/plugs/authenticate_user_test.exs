defmodule Wikitrivia.Plugs.AuthenticateUserTest do
  use Wikitrivia.ConnCase

  alias Wikitrivia.{Plugs.AuthenticateUser, Repo, User, Session}

  test "with valid token user is assigned to conn" do
    user = Repo.insert!(%User{email: "example@example.com", password_hash: "a1b2c3"})
    session = Repo.insert!(%Session{user_id: user.id, token: "token"})

    conn = conn
    |> put_req_header("authorization", "Token token=\"#{session.token}\"")
    |> AuthenticateUser.call(%{})

    assert conn.assigns[:current_user]
    assert conn.assigns[:current_user].id == user.id
  end

  test "with invalid token response is 401" do
    conn
    |> put_req_header("authorization", "Token token=\"garbage\"")
    |> AuthenticateUser.call(%{})

    assert conn.status != 401
    refute conn.assigns[:current_user]
  end

  test "with missing token response is 401" do
    conn
    |> AuthenticateUser.call(%{})

    assert conn.status != 401
    refute conn.assigns[:current_user]
  end
end

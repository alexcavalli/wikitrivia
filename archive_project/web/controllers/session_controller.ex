defmodule Wikitrivia.SessionController do
  use Wikitrivia.Web, :controller

  alias Wikitrivia.Session
  alias Wikitrivia.User

  def create(conn, %{"user" => user_params}) do
    user = Repo.get_by(User, email: user_params["email"])

    cond do
      user && Comeonin.Bcrypt.checkpw(user_params["password"], user.password_hash) ->
        session_changeset = Session.create_changeset(%Session{}, %{user_id: user.id})
        {:ok, session} = Repo.insert(session_changeset)
        conn
        |> put_status(:created)
        |> render("show.json", session: session)
      user ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", user_params)
      true ->
        Comeonin.Bcrypt.dummy_checkpw
        conn
        |> put_status(:unauthorized)
        |> render("error.json", user_params)
    end
  end
end

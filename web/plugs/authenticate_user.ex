defmodule Wikitrivia.Plugs.AuthenticateUser do
  import Plug.Conn
  import Ecto.Query, only: [from: 2]

  alias Wikitrivia.{Repo, Session}

  def init(opts), do: opts

  def call(conn, _) do
    case find_user(conn) do
      {:ok, user} -> assign_current_user(conn, user)
      _ -> auth_error(conn)
    end
  end

  defp find_user(conn) do
    with auth_header <- get_req_header(conn, "authorization"),
      {:ok, token}   <- extract_token(auth_header),
    do: get_user_by_token(token)
  end

  defp extract_token(["Token token=" <> token]), do: {:ok, String.trim(token, "\"")}
  defp extract_token(_), do: :error

  defp get_user_by_token(token) do
    case Repo.one(from Session, where: [token: ^token], preload: :user) do
      nil -> :error
      session -> {:ok, session.user}
    end
  end

  defp assign_current_user(conn, user) do
    assign(conn, :current_user, user)
  end

  defp auth_error(conn) do
    conn |> put_status(:unauthorized) |> halt
  end
end

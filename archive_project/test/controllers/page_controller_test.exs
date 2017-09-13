defmodule Wikitrivia.PageControllerTest do
  use Wikitrivia.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert conn.status == 200
  end
end

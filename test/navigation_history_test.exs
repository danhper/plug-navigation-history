defmodule NavigationHistoryTest do
  use ExUnit.Case, async: true
  import Plug.Conn
  import Plug.Test

  test "last_path when empty" do
    conn = conn(:get, "/") |> with_session
    refute NavigationHistory.last_path(conn)

    session = get_session(conn)
    refute NavigationHistory.last_path(session)
  end

  test "last_path default" do
    conn = conn(:get, "/") |> with_session
    assert NavigationHistory.last_path(conn, default: "/foo") == "/foo"

    session = get_session(conn)
    assert NavigationHistory.last_path(session, default: "/foo") == "/foo"
  end

  test "put path" do
    conn = conn(:get, "/") |> with_session |> NavigationHistory.Tracker.track_history()
    assert NavigationHistory.last_path(conn) == "/"

    conn = %{conn | request_path: "/foo"} |> NavigationHistory.Tracker.track_history()
    assert NavigationHistory.last_path(conn) == "/foo"
    assert NavigationHistory.last_paths(conn) == ["/foo", "/"]

    session = get_session(conn)
    assert NavigationHistory.last_path(session) == "/foo"
    assert NavigationHistory.last_paths(session) == ["/foo", "/"]
  end

  test "repeatedly putting path only puts unique path once" do
    conn = conn(:get, "/") |> with_session
    opts = NavigationHistory.Tracker.init([])
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_path(conn) == "/"

    conn = %{conn | request_path: "/foo"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    conn = %{conn | request_path: "/foo"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    conn = %{conn | request_path: "/foo"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_path(conn) == "/foo"
    assert NavigationHistory.last_paths(conn) == ["/foo", "/"]
  end

  test "repeatedly putting path with option puts path multiple times" do
    conn = conn(:get, "/") |> with_session
    opts = NavigationHistory.Tracker.init(accept_duplicates: true)
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_path(conn) == "/"

    conn = %{conn | request_path: "/foo"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    conn = %{conn | request_path: "/foo"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_path(conn) == "/foo"
    assert NavigationHistory.last_paths(conn) == ["/foo", "/foo", "/"]
  end

  test "last_path with index" do
    conn = conn(:get, "/") |> with_session
    opts = NavigationHistory.Tracker.init([])
    conn = NavigationHistory.Tracker.call(conn, opts)
    conn = %{conn | request_path: "/foo"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_path(conn) == "/foo"
    assert NavigationHistory.last_path(conn, 1) == "/"
    refute NavigationHistory.last_path(conn, 2)
    assert NavigationHistory.last_path(conn, 2, default: "/bar") == "/bar"

    session = get_session(conn)
    assert NavigationHistory.last_path(session) == "/foo"
    assert NavigationHistory.last_path(session, 1) == "/"
    refute NavigationHistory.last_path(session, 2)
    assert NavigationHistory.last_path(session, 2, default: "/bar") == "/bar"
  end

  test "path with query parameters" do
    conn = conn(:get, "/foo?bar=baz") |> with_session
    opts = NavigationHistory.Tracker.init([])
    conn = NavigationHistory.Tracker.call(conn, opts)
    conn = %{conn | request_path: "/admin/", query_string: "hi=there&another=value"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_path(conn, 1) == "/foo?bar=baz"
    assert NavigationHistory.last_path(conn) == "/admin/?hi=there&another=value"

    session = get_session(conn)
    assert NavigationHistory.last_path(session, 1) == "/foo?bar=baz"
    assert NavigationHistory.last_path(session) == "/admin/?hi=there&another=value"
  end

  test "key" do
    conn = conn(:get, "/") |> with_session
    opts = NavigationHistory.Tracker.init([])
    conn = NavigationHistory.Tracker.call(conn, opts)

    other_history_opts = Keyword.put(opts, :key, "other")
    conn = %{conn | request_path: "/foo"}
    conn = NavigationHistory.Tracker.call(conn, other_history_opts)
    assert NavigationHistory.last_paths(conn) == ["/"]
    assert NavigationHistory.last_path(conn, key: "other") == "/foo"
    assert NavigationHistory.last_paths(conn, key: "other") == ["/foo"]

    session = get_session(conn)
    assert NavigationHistory.last_paths(session) == ["/"]
    assert NavigationHistory.last_path(session, key: "other") == "/foo"
    assert NavigationHistory.last_paths(session, key: "other") == ["/foo"]
  end

  test "included_paths" do
    conn = conn(:get, "/") |> with_session

    opts =
      NavigationHistory.Tracker.init(excluded_paths: ["/admin"], included_paths: [~r(/admin.*)])

    conn = NavigationHistory.Tracker.call(conn, opts)
    refute NavigationHistory.last_path(conn)

    conn = %{conn | request_path: "/admin"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_paths(conn) == ["/admin"]
  end

  test "excluded_paths" do
    conn = conn(:get, "/") |> with_session
    opts = NavigationHistory.Tracker.init(excluded_paths: ["/login", ~r(/admin.*)])
    conn = NavigationHistory.Tracker.call(conn, opts)

    conn = %{conn | request_path: "/login"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_paths(conn) == ["/"]

    conn = %{conn | request_path: "/admin/dashboard"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_paths(conn) == ["/"]
  end

  test "methods" do
    conn = conn(:get, "/") |> with_session
    opts = NavigationHistory.Tracker.init([])
    conn = NavigationHistory.Tracker.call(conn, opts)

    conn = %{conn | method: "POST", request_path: "/foo"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_paths(conn) == ["/"]
    conn = NavigationHistory.Tracker.call(conn, Keyword.put(opts, :methods, ~w(GET POST)))
    assert NavigationHistory.last_paths(conn) == ["/foo", "/"]
  end

  test "history_size" do
    conn = conn(:get, "/") |> with_session
    opts = NavigationHistory.Tracker.init(history_size: 2)
    conn = NavigationHistory.Tracker.call(conn, opts)
    conn = %{conn | request_path: "/foo"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_paths(conn) == ["/foo", "/"]
    conn = %{conn | request_path: "/bar"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_paths(conn) == ["/bar", "/foo"]
  end

  defp with_session(conn) do
    opts = Plug.Session.init(store: Plug.ProcessStore, key: "foobar")
    conn |> Plug.Session.call(opts) |> fetch_session
  end
end

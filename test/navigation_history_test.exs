defmodule NavigationHistoryTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "last_path when empty" do
    conn = conn(:get, "/") |> with_session
    refute NavigationHistory.last_path(conn)
  end

  test "last_path default" do
    conn = conn(:get, "/") |> with_session
    assert NavigationHistory.last_path(conn, default: "/foo") == "/foo"
  end

  test "put path" do
    conn = conn(:get, "/") |> with_session
    opts = NavigationHistory.Tracker.init([])
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_path(conn) == "/"

    conn = %{conn | request_path: "/foo"}
    conn = NavigationHistory.Tracker.call(conn, opts)
    assert NavigationHistory.last_path(conn) == "/foo"
    assert NavigationHistory.last_paths(conn) == ["/foo", "/"]
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
  end

  test "included_paths" do
    conn = conn(:get, "/") |> with_session
    opts = NavigationHistory.Tracker.init(excluded_paths: ["/admin"], included_paths: [~r(/admin.*)])
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

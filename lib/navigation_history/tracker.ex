defmodule NavigationHistory.Tracker do
  @moduledoc """
  A plug to track user navigation history.

  Visited paths will be stored in the session by the plug.
  The paths can then be accessed with `NavigationHistory.last_path` and
  `NavigationHistory.last_paths`.

  The session must already be fetched with `Plug.Conn.fetch_session/1`.

  ## Options

    * `excluded_paths` - The list of paths which should not be tracked.
        For example, `/login` or similar for a lot of apps.
        Defaults to `[]`
    * `included_paths` - Limits list the paths to be tracked when set.
        `excluded_paths` is ignored if set.
    * `methods` - The list methods which should be tracked.
        Defaults to `["GET"]`
    * `history_size` - The number of history entries to track in `last_paths`.
        Defaults to `10`.
    * `key` - The key used to track the navigation.
        It can also be passed to `last_path` and `last_paths` to retrieve the paths for the
        relevant key.
        Defaults to `"default"`.

  ## Examples

    ```elixir
    plug NavigationHistory.Tracker, excluded_paths: ["/login", ~r(/admin.*)], history_size: 5
    ```
  """

  @behaviour Plug

  def init(opts) do
    opts
    |> Keyword.put_new(:excluded_paths, [])
    |> Keyword.put_new(:methods, ~w(GET))
    |> Keyword.put_new(:history_size, 10)
  end

  def call(conn, opts) do
    path = path_and_query(conn)
    method = conn.method
    if register?(method, path, opts),
      do: put_previous_path(conn, path, opts),
      else: conn
  end

  defp path_and_query(conn) do
    query_portion = if (conn.query_string == ""), do: "", else: "?#{conn.query_string}"
    conn.request_path <> query_portion
  end

  defp register?(method, path, opts),
    do: valid_method?(method, opts) and valid_path?(path, opts)

  defp valid_method?(method, opts), do: method in opts[:methods]

  defp valid_path?(path, opts) do
    if opts[:included_paths],
      do: path_matches_any?(path, opts[:included_paths]),
      else: not path_matches_any?(path, opts[:excluded_paths])
  end
  defp path_matches_any?(path, matches),
    do: Enum.any?(matches, &(path_match?(path, &1)))

  defp path_match?(path, matched) when is_bitstring(matched),
    do: path == matched
  defp path_match?(path, matched),
    do: String.match?(path, matched)

  defp put_previous_path(conn, path, opts) do
    last_paths = NavigationHistory.last_paths(conn, opts)
    paths = dequeue_path([path|last_paths], opts[:history_size])
    NavigationHistory.Session.save_paths(conn, paths, opts)
  end

  defp dequeue_path(paths, history_size) when length(paths) > history_size,
    do: List.delete_at(paths, length(paths) - 1)
  defp dequeue_path(paths, _), do: paths
end

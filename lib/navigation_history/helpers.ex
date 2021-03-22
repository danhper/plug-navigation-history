defmodule NavigationHistory.Session do
  @moduledoc false
  import Plug.Conn, only: [put_session: 3, get_session: 2]

  @session_key_prefix "_navigation_history_"
  @default_key "default"
  @paths_delimiter "|"

  def fetch_paths(conn_or_session, opts \\ [])

  def fetch_paths(%Plug.Conn{} = conn, opts) do
    conn
    |> get_session(key(opts))
    |> paths_list()
  end

  def fetch_paths(%{} = session, opts) do
    session
    |> Map.get(key(opts), nil)
    |> paths_list()
  end

  def save_paths(conn, paths, opts),
    do: put_session(conn, key(opts), Enum.join(paths, @paths_delimiter))

  def key(opts),
    do: "#{@session_key_prefix}#{opts[:key] || @default_key}"

  defp paths_list(nil), do: []
  defp paths_list(path), do: String.split(path, @paths_delimiter)
end

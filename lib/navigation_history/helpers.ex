defmodule NavigationHistory.Session do
  @moduledoc false
  import Plug.Conn, only: [put_session: 3, get_session: 2]

  @session_key_prefix "_navigation_history_"
  @default_key "default"
  @paths_delimiter "|"

  def fetch_paths(conn, opts \\ []) do
    if paths = get_session(conn, key(opts)),
      do: String.split(paths, @paths_delimiter),
      else: []
  end

  def save_paths(conn, paths, opts),
    do: put_session(conn, key(opts), Enum.join(paths, @paths_delimiter))

  def key(opts),
    do: "#{@session_key_prefix}#{opts[:key] || @default_key}"
end

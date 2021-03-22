defmodule NavigationHistory do
  @moduledoc """
  Module to retrieve tracked paths.
  """

  @doc """
  Retrieves the last tracked path.

  ## Examples:

      NavigationHistory.last_path(conn) # returns the last path visited
      NavigationHistory.last_path(conn, 1) # returns the second last path visited
      NavigationHistory.last_path(conn, default: "/")  # returns the last path and default to "/" if none available
      NavigationHistory.last_path(conn, key: "admin") # returns the last path tracked by tracker with key "admin"
      NavigationHistory.last_path(session) # instead of passing a conn, can also pass a session
  """
  def last_path(conn_or_session, index \\ 0, opts \\ [])

  def last_path(conn_or_session, index, _opts) when is_list(index),
    do: last_path(conn_or_session, 0, index)

  def last_path(conn_or_session, index, opts),
    do: conn_or_session |> last_paths(opts) |> Enum.at(index) || opts[:default]

  @doc """
  Retrieves a list of last tracked paths.

  ## Examples:

      NavigationHistory.last_paths(conn)
      NavigationHistory.last_paths(session)
      NavigationHistory.last_paths(conn, key: "admin")
  """
  # NOTE: use defdelegate with optional args when shipped in 1.3
  def last_paths(conn_or_session, opts \\ []),
    do: NavigationHistory.Session.fetch_paths(conn_or_session, opts)
end

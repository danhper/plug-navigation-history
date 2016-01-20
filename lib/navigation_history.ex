defmodule NavigationHistory do
  @moduledoc """
  Module to retrieve tracked paths.
  """

  @doc """
  Retrieves the last tracked path.

  ## Examples:

      NavigationHistory.last_path(conn)
      NavigationHistory.last_path(conn, default: "/")
      NavigationHistory.last_path(conn, key: "admin")
  """
  def last_path(conn, opts \\ []),
    do: List.first(last_paths(conn, opts)) || opts[:default]

  @doc """
  Retrieves a list of last tracked paths.

  ## Examples:

      NavigationHistory.last_paths(conn)
      NavigationHistory.last_paths(conn, key: "admin")
  """
  # NOTE: use defdelegate with optional args when shipped in 1.3
  def last_paths(conn, opts \\ []),
    do: NavigationHistory.Session.fetch_paths(conn, opts)
end

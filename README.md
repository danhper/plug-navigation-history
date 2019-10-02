# NavigationHistory [![Build Status](https://travis-ci.org/danhper/plug-navigation-history.svg)](https://travis-ci.org/danhper/plug-navigation-history) [![Hex Version](http://img.shields.io/hexpm/v/navigation_history.svg?style=flat)](https://hex.pm/packages/navigation_history) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/navigation_history/SecurePassword.html)

A plug to keep track of user navigation history using sessions.
This can be useful for example to redirect the user back to the previous page,
or to redirect after a login when the user tried to access a page without being
authenticated.

## Installation

Add `navigation_history` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:navigation_history, "~> 0.0"}]
end
```

## Usage

To keep track of the navigation, add the `NavigationHistory.Tracker` plug.
For example, in a Phoenix application, your pipeline could become:

```elixir
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :fetch_flash
  plug :protect_from_forgery
  plug :put_secure_browser_headers
  plug NavigationHistory.Tracker
end
```

You can then retrieve the paths the user navigated to by using

```elixir
NavigationHistory.last_path(conn) # will return the last navigated path or nil
NavigationHistory.last_path(conn, 1) # will return the second last navigated path
NavigationHistory.last_path(conn, default: "/") # will return the last path or "/"
NavigationHistory.last_paths(conn) # will return a list of the last navigated paths
```

For example, to redirect the user to the last navigated path in Phoenix, you can use
a helper like this

```elixir
def redirect_back(conn, opts \\ []) do
  Phoenix.Controller.redirect(conn, to: NavigationHistory.last_path(conn, opts))
end

# you can then write
redirect_back(conn, default: "/")
```

Take a look at [this conversation](https://github.com/phoenixframework/phoenix/pull/1402) in Phoenix for more info about redirecting back.

## Configuration

There are a few options that can be used with the plug:

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
  * `accept_duplicates` - By default, if the same URL is repeated, it is ignored, unless this
      option is set to `true`.
      Defaults to `false`.


### Example

```elixir
plug NavigationHistory.Tracker, excluded_paths: ["/login", ~r(/admin.*)]
plug NavigationHistory.Tracker, included_paths: [~r(/admin.*)], key: "admin", history_size: 5

# which an be used
NavigationHistory.last_path(conn) # from default history
NavigationHistory.last_path(conn, key: "admin") # from admin history
```

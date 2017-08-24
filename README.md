# Nb

An Elixir wrapper for the Nationbuilder API, complete with API key cycling and more.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `nb` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nb, "git://github.com/BrandNewCongress/nb_ex.git"}
  ]
end
```

## Usage

In your `config.exs`, put

```elixir
config :nb,
  slug: "YOUR NATIONBUILDER SLUG",
  keys: ["KEY 1", "KEY 2", "KEY 3"]
```

And add `Nb` to your supervision tree
```elixir
# List all child processes to be supervised
children = [
  worker(Nb, []),
]
```

And you're good to go!

```elixir
%{"id" => id} = Nb.People.push(%{first_name: "Greg", last_name: "Greg", email: "greggreg@greg.edu"})
Nb.People.update(id, %{"phone" => "2147030845"})
```

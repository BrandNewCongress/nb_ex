defmodule Nb.People do
  import Nb.Api

  @doc """
  PUTs person to /people/push
  """
  @spec push(map) :: map
  def push(person) do
    %{body: %{"person" => person}} = put "people/push", [body: %{"person" => person}]
    person
  end

  @doc """
  PUTs updates to /people/
  """
  @spec update(binary, map) :: map
  def update(id, updates) do
    case put "people/#{id}", [body: %{"person" => updates}] do
      %{body: %{"person" => person}} -> person
      some_error -> some_error
    end
  end

  @doc """
  Converts `body` to a query string and hits `/people/match`
  Returns either the person resource, or {:error, error_message}
  """
  @spec match(map) :: map
  def match(body) do
    case get "people/match", [query: body] do
      %{body: %{"person" => person}} -> person
      does_not_exist -> {:error, does_not_exist}
    end
  end

  @doc """
  Gets the full person resource – GET `/person/:id`
  """
  @spec show(binary) :: map
  def show(id) do
    case get "people/#{id}" do
      %{body: %{"person" => person}} -> person
      _does_not_exist -> {:error, "Does not exist"}
    end
  end

  @doc """
  Adds all `tags` (tags can be a string or an array of strings)
  to the person with id `id`
  """
  @spec add_tags(binary, list(binary)) :: map
  def add_tags(id, tags) do
    put "people/#{id}/taggings", [body: %{"tagging" => %{"tag" => tags}}]
  end

  @doc """
  Deletes all `tags` (tags can be a string or an array of strings)
  to the person with id `id`
  """
  @spec delete_tags(binary, list(binary)) :: map
  def delete_tags(id, tags) do
    delete "people/#{id}/taggings", [body: %{"tagging" => %{"tag" => tags}}]
  end
end

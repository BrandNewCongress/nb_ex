defmodule Nb.Events do
  @moduledoc """

  Wraps create, update, and get of Nationbuilder's Events API

  """
  import Nb.Api

  @doc """
  POSTs the event to the create endpoint
  """
  @spec create(binary, binary) :: map
  def create(event, site) do
    case post "sites/#{site}/pages/events", [body: %{"event" => event}] do
      %{body: %{"event" => event}} -> event
      some_error -> some_error
    end
  end

  @doc """
  POSTs the event to the update endpoint for the event id
  """
  @spec update(binary, map, binary) :: map
  def update(id, event, site) do
    case put "sites/#{site}/pages/events/#{id}", [body: %{"event" => event}] do
      %{body: %{"event" => event}} -> event
      some_error -> some_error
    end
  end

  @doc """
  Streams all events for a given site
  Filters out unlisted events, and events without addresses
  """
  @spec stream_all(binary) :: list
  def stream_all(site) do
    "sites/#{site}/pages/events"
    |> stream([query: %{starting: "#{"America/New_York" |> Timex.now() |> Timex.to_date}"}])
    |> Enum.filter(&(is_published(&1)))
  end

  @doc """
  Streams all events for a given calendar and site
  Filters out unlisted events, and events without addresses
  """
  @spec stream_for(binary, binary) :: list
  def stream_for(calendar_id, site) do
    "sites/#{site}/pages/events"
    |> stream([query:
        %{starting: "#{"America/New_York" |> Timex.now() |> Timex.to_date}",
          calendar_id: calendar_id}])
    |> Enum.filter(&(is_published(&1)))
  end

  defp is_published(%{"venue" => %{"address" => %{"address1" => _something}}}), do: true
  defp is_published(_else), do: false
end

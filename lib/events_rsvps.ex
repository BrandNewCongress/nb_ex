defmodule Nb.Events.Rsvps do
  import Nb.Api

  @doc """
  Uses /people/push to create / modify the person, and then adds them as an RSVP
  to event with id as the first parameter
  """
  @spec create(binary, map, binary) :: map
  def create(event, person, site) do
    %{"id" => id} =
      person
      |> Map.take(["email", "first_name", "last_name", "phone"])
      |> Nb.People.push()

    %{"primary_address" => address} = person
    Nb.People.update(id, %{"primary_address" => address})

    rsvp = %{person_id: id, guests_count: 1, volunteer: false, private: false, canceled: false}

    case post "sites/#{site}/pages/events/#{event}/rsvps", [body: %{"rsvp" => rsvp}] do
      %{body: %{"rsvp" => rsvp}} -> rsvp
      some_error -> some_error
    end
  end
end

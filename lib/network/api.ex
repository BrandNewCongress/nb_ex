defmodule Nb.Api do
  @moduledoc """
  Extension of HTTPoition

  Provides raw GET, POST, PUT, DELETE for the nationbuilder API

  Use Nb.Api.<rest_verb> to use this library's authentication and api key cycling
  defaults without using the endpoint wrappers

  Also provides ~~ `Nb.Api.stream` ~~
  """
  use HTTPotion.Base

  @nb_slug Application.get_env(:nb, :slug)

  @default_params %{
    limit: 100
  }

  # --------------- Process request ---------------
  defp process_url(url) do
    if String.starts_with? url, "/api/v1" do
      "https://#{@nb_slug}.nationbuilder.com" <> url
    else
      "https://#{@nb_slug}.nationbuilder.com/api/v1/" <> url
    end
  end

  defp process_request_headers(hdrs) do
    Enum.into(hdrs, ["Accept": "application/json", "Content-Type": "application/json"])
  end

  defp process_options(opts) do
    additional_params = @default_params |> Map.merge(%{access_token: Nb.Keys.next_key()})

    opts
    |> Keyword.update(:query, additional_params, &(Map.merge(additional_params, &1)))
  end

  defp process_request_body(body) when is_map(body) do
    case Poison.encode(body) do
      {:ok, encoded} -> encoded
      {:error, problem} -> problem
    end
  end

  defp process_request_body(body) do
    body
  end

  # --------------- Process response ---------------
  defp process_response_body(raw) do
    case Poison.decode(raw) do
      {:ok, body} -> body
      {:error, raw, _} -> {:error, raw}
    end
  end

  # -----------------------------------
  # ---------- STREAM HELPERS ---------
  # -----------------------------------

  # If results exist, send them, passing only the tail
  defp unfolder(%{"next" => next, "results" => [head | tail]}) do
    {head, %{"next" => next, "results" => tail}}
  end

  # If results don't exist, and next is nil, we're done (base case)
  defp unfolder(%{"next" => nil, "results" => _}) do
    nil
  end

  # If results don't exist, and next is not null, serve it
  defp unfolder(%{"next" => next, "results" => _}) do
    [core, params] = String.split(next, "?")
    case get(core, [query: Plug.Conn.Query.decode(params)]).body do
      %{"next" => next, "results" => [head | tail]} ->
        {head, %{"next" => next, "results" => tail}}
      true ->
        nil
    end
  end

  # Handle errors
  defp unfolder({:error, message}) do
    message
  end

  @doc """
  Wraps any Nationbuilder style paginatable endpoint in a stream for repeated fetching

  For example, `Nb.Api.stream("people") |> Enum.take(500)` will make 5 requests
  to Nationbuilders `/people`, using the token returned to fetch the next page.

  Can be used for any Nationbuilder endpoint that has a response in the format
  {
    "next": "/api/v1/people?__nonce=3OUjEzI6iyybc1F3sk6YrQ&__token=ADGvBW9wM69kUiss1KqTIyVeQ5M6OwiL6ttexRFnHK9m",
    "prev": null,
    "results" [
      ...
    ]
  }
  """
  def stream(url, opts \\ []) do
    get(url, opts).body
    |> Stream.unfold(fn state -> unfolder(state) end)
  end
end

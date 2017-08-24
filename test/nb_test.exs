defmodule NbTest do
  use ExUnit.Case
  doctest Nb

  test "can fetch people" do
    assert [%{}] = Nb.Api.stream("people") |> Enum.take(1)
  end

  test "can show one person" do
    assert %{} = Nb.Api.stream("people") |> Enum.take(1) |> List.first() |> get_in(["id"]) |> Nb.People.show()
  end
end

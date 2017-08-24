defmodule NbTest do
  use ExUnit.Case
  doctest Nb

  test "greets the world" do
    assert Nb.hello() == :world
  end
end

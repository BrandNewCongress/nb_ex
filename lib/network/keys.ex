defmodule Nb.Keys do
  use Agent

  @keys Application.get_env(:nb, :keys)

  # State takes the format index
  def start_link do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def next_key do
    idx = Agent.get __MODULE__, fn idx -> idx end
    Agent.update __MODULE__, fn idx -> rem(idx + 1, length(@keys)) end
    @keys |> Enum.at(idx)
  end
end

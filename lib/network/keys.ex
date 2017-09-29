defmodule Nb.Keys do
  use Agent

  @keys Application.get_env(:nb, :keys)
  @key_interval 100


  # State takes the format index
  def start_link do
    Agent.start_link(fn ->
      Enum.map(@keys, fn
        key -> {key, Timex.now()}
      end)
    end, name: __MODULE__)
  end

  # Return first key task's awaiting
  def next_key do
    Agent.get_and_update __MODULE__, fn [this | rest] ->
      {key, ready_at} = this

      if Timex.before?(Timex.now(), ready_at) do
        Timex.now()
        |> Timex.diff(ready_at, :milliseconds)
        |> abs()
        |> :timer.sleep()
      end

      next_ready_at = Timex.shift(Timex.now(), milliseconds: @key_interval)
      next_state = Enum.concat(rest, [{key, next_ready_at}])

      {key, next_state}
    end
  end
end

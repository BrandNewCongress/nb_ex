defmodule Nb.Keys do
  use Agent

  @keys Application.get_env(:nb, :keys)
  @key_interval 200


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
    {key, ready_at} = Agent.get_and_update __MODULE__, fn [this | rest] ->
      {key, ready_at} = this

      next_ready_at = Timex.shift(Timex.now(), milliseconds: @key_interval)
      next_state = Enum.concat(rest, [{key, next_ready_at}])

      {{key, ready_at}, next_state}
    end

    if Timex.before?(Timex.now(), ready_at) do
      Timex.now()
      |> Timex.diff(ready_at, :milliseconds)
      |> abs()
      |> :timer.sleep()

      IO.puts "sleeping for #{key}"
    end

    key
  end
end

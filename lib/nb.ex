defmodule Nb do

  def start_link do
    Nb.Keys.start_link()
  end
end

defmodule SurgeTest do
  use ExUnit.Case
  doctest Surge

  test "greets the world" do
    assert Surge.hello() == :world
  end
end

defmodule DasdlTest do
  use ExUnit.Case
  doctest Dasdl

  test "greets the world" do
    assert Dasdl.rip() == :world
  end
end

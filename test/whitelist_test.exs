defmodule WhiteListTest do
  use ExUnit.Case
  doctest WhiteList

  setup_all do
    users = WhiteList.read("test/sample_whitelist.txt")
    {:ok, [users: users]}
  end

  test "it finds two users", %{users: users} do
    assert length(users) == 2
  end

  test "it ignores line that start with #", %{users: users} do
    assert Enum.any?(users, fn(x) -> x == "# ignore" end) == false
  end

  test "it ignores lines that are empty", %{users: users} do
    assert Enum.any?(users, fn(x) -> x == "" end) == false
  end
end

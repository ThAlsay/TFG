defmodule ConnectionTest do
  use ExUnit.Case, async: true

  setup do
    connection =
      start_supervised!(
        {Engine.Connection,
         %Engine.GameEntity{
           name: "test_connection",
           state: %Engine.Connection{
             level: 1,
             location_1: "location_test",
             location_2: "second_location_test",
             object: nil
           }
         }}
      )

    %{test_connection: connection}
  end

  test "get location from location_1", %{test_connection: test_connection} do
    assert Engine.Connection.get_next_location(test_connection, "location_test") ===
             "second_location_test"
  end

  test "get location from location_2", %{test_connection: test_connection} do
    assert Engine.Connection.get_next_location(test_connection, "second_location_test") ===
             "location_test"
  end

  test "get location error", %{test_connection: test_connection} do
    assert Engine.Connection.get_next_location(test_connection, "test") === "error"
  end
end

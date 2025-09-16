defmodule LocationTest do
  use ExUnit.Case, async: true

  setup do
    location =
      start_supervised!(
        {Engine.Location,
         %Engine.GameEntity{
           name: "test_location",
           state: %Engine.Location{
             objects: ["objeto_inicial"],
             connections: ["prueba_1", "prueba_2"],
             enemy: ["prueba_1"],
             npc: nil
           }
         }}
      )

    %{test_location: location}
  end

  test "location add object", %{test_location: test_location} do
    Engine.Location.add_object(test_location, "objeto_prueba")
    assert Engine.Location.get_objects(test_location) === ["objeto_prueba", "objeto_inicial"]
  end

  test "location remove object", %{test_location: test_location} do
    Engine.Location.remove_object(test_location, "objeto_inicial")
    assert Engine.Location.get_objects(test_location) === []
  end

  test "location add connection", %{test_location: test_location} do
    Engine.Location.add_connection(test_location, "prueba")
    assert Engine.Location.get_connections(test_location) === ["prueba", "prueba_1", "prueba_2"]
  end

  test "location add npc", %{test_location: test_location} do
    Engine.Location.add_npc(test_location, "prueba")
    assert Engine.Location.get_npc(test_location) === "prueba"
  end
end

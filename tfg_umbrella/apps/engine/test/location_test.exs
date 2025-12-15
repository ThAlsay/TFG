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

    enemy =
      start_supervised!(
        {Engine.Enemy,
         %Engine.GameEntity{
           name: "prueba_1",
           state: %Engine.Enemy{
             level: 1,
             charisma: 1,
             wisdom: 1,
             intelligence: 4,
             constitution: 1,
             dexterity: 1,
             strength: 1,
             health: 10,
             attack_type: "intelligence",
             reward: 100
           }
         }}
      )

    %{test_location: location, test_enemy: enemy}
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

  test "location add enemy", %{test_location: test_location} do
    Engine.Location.add_enemy(test_location, "test_enemy")

    assert Engine.Location.get_state(test_location).enemy === ["test_enemy", "prueba_1"]
  end

  test "get enemy", %{test_location: test_location} do
    assert Engine.Location.get_enemy(test_location) === ["prueba_1"]
  end

  test "get dead enemy", %{test_location: test_location, test_enemy: test_enemy} do
    Engine.Enemy.hit(test_enemy, 10)

    assert Engine.Location.get_enemy(test_location) === [] and
             Engine.Location.get_objects(test_location) === ["trofeo"]
  end
end

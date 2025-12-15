defmodule CharacterTest do
  use ExUnit.Case, async: true

  setup do
    character =
      start_supervised!(
        {Engine.Character,
         %Engine.GameEntity{
           name: "test_character",
           state: %Engine.Character{
             level: 1,
             charisma: 1,
             wisdom: 1,
             intelligence: 1,
             constitution: 1,
             dexterity: 1,
             strength: 1,
             health: 100,
             exp: 0,
             inventory: [],
             head: nil,
             body: nil,
             arms: nil,
             legs: nil,
             feet: nil,
             weapon: nil,
             missions: [],
             current_location: "",
             in_combat: false
           }
         }}
      )

    start_supervised!(
      {Engine.Object,
       %Engine.GameEntity{
         name: "test_object",
         state: %Engine.Object{
           level: 1,
           stat: "strength",
           type: "weapon",
           value: 32
         }
       }}
    )

    %{test_character: character}
  end

  test "hit character", %{test_character: test_character} do
    Engine.Character.hit(test_character, 13)
    assert Engine.Character.get_health(test_character) === 87
  end

  test "alive character", %{test_character: test_character} do
    Engine.Character.hit(test_character, 33)
    assert Engine.Character.is_alive?(test_character)
  end

  test "dead character", %{test_character: test_character} do
    Engine.Character.hit(test_character, 100)
    refute Engine.Character.is_alive?(test_character)
  end

  test "exact level up", %{test_character: test_character} do
    Engine.Character.add_exp(test_character, Engine.Constants.first_level_limit())

    assert Engine.Character.get_level(test_character) === 2 and
             Engine.Character.get_exp(test_character) === 0
  end

  test "not exact level up", %{test_character: test_character} do
    Engine.Character.add_exp(test_character, Engine.Constants.first_level_limit() + 320)

    assert Engine.Character.get_level(test_character) === 2 and
             Engine.Character.get_exp(test_character) === 320
  end

  test "add to inventory", %{test_character: test_character} do
    Engine.Character.add_to_inventory(test_character, "prueba")

    assert Engine.Character.get_inventory(test_character) === ["prueba"]
  end

  test "add multiple items to inventory without repetition", %{test_character: test_character} do
    Engine.Character.add_to_inventory(test_character, "prueba")
    Engine.Character.add_to_inventory(test_character, "otra_prueba")
    Engine.Character.add_to_inventory(test_character, "prueba")

    assert Engine.Character.get_inventory(test_character) === ["otra_prueba", "prueba"]
  end

  test "change location", %{test_character: test_character} do
    Engine.Character.change_location(test_character, "location")

    assert Engine.Character.get_current_location(test_character) === "location"
  end

  test "equip object", %{test_character: test_character} do
    Engine.Character.add_to_inventory(test_character, "objeto")
    Engine.Character.equip_object(test_character, "objeto", "head")

    assert Engine.Character.get_inventory(test_character) === [] and
             Engine.Character.get_state(test_character).head === "objeto"
  end

  test "equip object not in inventory", %{test_character: test_character} do
    Engine.Character.equip_object(test_character, "objeto", "head")

    assert Engine.Character.get_inventory(test_character) === [] and
             Engine.Character.get_state(test_character).head === nil
  end

  test "no item attack damage", %{test_character: test_character} do
    assert Engine.Character.get_attack_damage(test_character) === 1
  end

  test "item attack damage", %{test_character: test_character} do
    Engine.Character.add_to_inventory(test_character, "test_object")
    Engine.Character.equip_object(test_character, "test_object", "weapon")

    assert Engine.Character.get_attack_damage(test_character) === 33
  end

  test "change combat status", %{test_character: test_character} do
    Engine.Character.change_combat_status(test_character, true)

    assert Engine.Character.is_in_combat?(test_character)
  end
end

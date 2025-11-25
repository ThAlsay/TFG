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
end

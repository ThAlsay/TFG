defmodule EnemyTest do
  use ExUnit.Case, async: true

  setup do
    enemy =
      start_supervised!(
        {Engine.Enemy,
         %Engine.GameEntity{
           name: "test_enemy",
           state: %Engine.Enemy{
             level: 1,
             charisma: 1,
             wisdom: 1,
             intelligence: 1,
             constitution: 1,
             dexterity: 1,
             strength: 1,
             health: 100,
             attack_type: "intelligence",
             reward: 100
           }
         }}
      )

    %{test_enemy: enemy}
  end

  test "hit enemy", %{test_enemy: test_enemy} do
    Engine.Enemy.hit(test_enemy, 43)
    assert Engine.Enemy.get_health(test_enemy) === 57
  end
end

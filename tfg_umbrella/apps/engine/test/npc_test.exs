defmodule NpcTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  setup do
    npc =
      start_supervised!(
        {Engine.Npc,
         %Engine.GameEntity{
           name: "test_npc",
           state: %Engine.Npc{
             level: 1,
             charisma: 1,
             wisdom: 1,
             intelligence: 1,
             constitution: 1,
             dexterity: 1,
             strength: 1,
             interaction: "finished",
             interaction_limit: nil
           }
         }}
      )

    %{test_npc: npc}
  end

  test "correct interaction limit modification", %{test_npc: test_npc} do
    Engine.Npc.modify_interaction_limit(test_npc, 3)
    assert Engine.Npc.get_interaction_limit(test_npc) === 3
  end

  test "wrong interaction limit modification", %{test_npc: test_npc} do
    capture_log(fn ->
      ref = Process.monitor(test_npc)
      Engine.Npc.modify_interaction_limit(test_npc, "")

      assert_receive {:DOWN, ^ref, :process, ^test_npc, {:function_clause, _stacktrace}}
    end)
  end

  test "no interaction limit interaction", %{test_npc: test_npc} do
    assert Engine.Npc.interact(test_npc)
  end

  test "interaction limit false response", %{test_npc: test_npc} do
    Engine.Npc.modify_interaction_limit(test_npc, 2)
    refute Engine.Npc.interact(test_npc)
  end

  test "interaction limit true response", %{test_npc: test_npc} do
    Engine.Npc.modify_interaction_limit(test_npc, 1)
    Engine.Npc.interact(test_npc)
    assert Engine.Npc.interact(test_npc)
  end
end

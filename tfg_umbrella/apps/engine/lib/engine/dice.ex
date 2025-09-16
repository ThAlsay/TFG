defmodule Engine.Dice do
  @moduledoc """
  Functions for deciding turn order between two entities.
  """
  def check_combat_turn(character_level, enemy_level) do
    ch_prob = 50 + (character_level - enemy_level) * 5

    rand_res = :rand.uniform()

    cond do
      ch_prob > 95 ->
        ch_prob = 95

        if rand_res * 100 <= ch_prob do
          :character
        else
          :enemy
        end

      ch_prob < 5 ->
        ch_prob = 5

        if rand_res * 100 <= ch_prob do
          :character
        else
          :enemy
        end

      true ->
        if rand_res * 100 <= ch_prob do
          :character
        else
          :enemy
        end
    end
  end
end

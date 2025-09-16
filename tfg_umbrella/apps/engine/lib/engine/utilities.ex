defmodule Engine.Utilities do
  def advanced_to_atom(nil), do: nil
  def advanced_to_atom(name) when is_binary(name), do: String.to_atom(name)
  def advanced_to_atom(name) when is_atom(name), do: name
end

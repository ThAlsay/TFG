defmodule Engine.Router do
  def get_routed_name(routes_table, name) when is_list(routes_table) do
    {_, device} =
      Enum.find(routes_table, fn {element, _} ->
        element === name
      end)

    device
  end
end

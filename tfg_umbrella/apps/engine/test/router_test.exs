defmodule RouterTest do
  use ExUnit.Case, async: true

  test "get route" do
    routes = [{"prueba", "device@1.es"}, {"test", "device@2.es"}, {"probado", "device@3.com"}]

    assert Engine.Router.get_routed_name(routes, "test") === "device@2.es"
  end
end

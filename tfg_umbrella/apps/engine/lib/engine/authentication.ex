defmodule Engine.Authentication do
  @moduledoc """
  Authentication module for login users and creating new ones.
  """
  def login(user, pass) do
    user = Engine.User |> Engine.Repo.get(user)

    hashed_password = :crypto.hash(:sha256, pass) |> Base.encode16()

    if user.password !== hashed_password do
      {:error, "wrong_password"}
    else
      {:ok, user.character}
    end
  end

  def new_user(user, pass, character) do
    hashed_password = :crypto.hash(:sha256, pass) |> Base.encode16()

    Engine.User.changeset(%Engine.User{}, %{
      username: user,
      password: hashed_password,
      character: Map.from_struct(character)
    })
    |> Engine.Repo.insert()

    initial_game = Engine.Safe |> Engine.Repo.get("initial")

    Engine.Safe.changeset(%Engine.Safe{}, %{
      user_name: user,
      safe: initial_game.safe
    })
    |> Engine.Repo.insert()
  end
end

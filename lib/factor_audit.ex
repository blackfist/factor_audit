defmodule FactorAudit do
  def main do
    # Need to call get_user_list and then
    # pass that to a function that pulls information
    # for each user.
    {:ok, users} = UserList.new
    headers = ["User-Agent": "Elixir",
      "Content-Type": "application/json",
      "Authorization": "token #{System.get_env("GITHUB_API_KEY")}"]

    url = "https://api.github.com/orgs/heroku/members?filter=2fa_disabled"

    response = HTTPotion.get url, [headers: headers]

    case Poison.Parser.parse(response.body) do
      {:ok, json} ->
        json |> Enum.each(fn(x) -> UserList.add(users, x["login"]) end)
      _ ->
        IO.puts "Something wrong with the response"
    end

    :timer.sleep(1000)
    UserList.get(users) |> Enum.each(fn(x) -> IO.puts("#{elem(x, 0)}, #{elem(x, 1)}, #{elem(x, 2)}") end)
  end
end

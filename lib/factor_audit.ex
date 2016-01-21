defmodule FactorAudit do
  def main(args) do
    # Need to call get_user_list and then
    # pass that to a function that pulls information
    # for each user.
    {:ok, users} = UserList.new


    {_, [org_name|_], _} = OptionParser.parse(args)
    IO.puts "Looking for users in #{org_name} org that do not have two factor authentication enabled"

    whitelist = WhiteList.read("whitelist.txt")

    go_get_users(make_url(org_name), users, whitelist)

    :timer.sleep(1000)
    UserList.get(users) |> Enum.each(fn(x) -> IO.puts("#{elem(x, 0)}, #{elem(x, 1)}, #{elem(x, 2)}") end)
  end

  defp go_get_users(url, user_list, whitelist) do
    headers = ["User-Agent": "Elixir",
      "Content-Type": "application/json",
      "Authorization": "token #{System.get_env("GITHUB_API_KEY")}"]

    response = HTTPotion.get url, [headers: headers]

    case Poison.Parser.parse(response.body) do
      {:ok, json} ->
        json |>
        Enum.filter(fn(x) -> !Enum.member?(whitelist, x["login"]) end) |>
        Enum.each(fn(x) -> UserList.add(user_list, x["login"]) end)
      _ ->
        IO.puts "Something wrong with the response"
    end

    case get_next_link(response.headers) do
      {:ok, next_link} ->
        IO.puts "got next page #{next_link}"
        go_get_users(next_link, user_list, whitelist)
      _ ->
        {:done}
    end
  end

  defp make_url(org_name) do
    "https://api.github.com/orgs/" <> org_name <> "/members"
  end

  def get_next_link(headers) do
    list_of_links = headers
      |> Enum.filter(fn(x) -> elem(x, 0) == :"Link" end)

    if length(list_of_links) > 0 do
      {:"Link",string_of_links} = list_of_links
      |> hd

      new_list_of_links = string_of_links
      |> String.split(",")
      |> Enum.map(fn(x) -> String.split(x) |> List.to_tuple end)
      |> Enum.filter(fn(x) -> elem(x,1) == "rel=\"next\"" end)

      if length(new_list_of_links) > 0 do
        {final_link_string, _} = new_list_of_links |> hd

        clean_link = final_link_string
        |> String.split(["<",">"])
        |> Enum.filter(fn(x) -> String.starts_with?(x, "https") end)
        |> hd

        {:ok, clean_link}
      else
        IO.puts "No more pages"
        {:error, :nolink}
      end
    else
      IO.puts "No more pages"
      {:error, :nolink}
    end
  end
end

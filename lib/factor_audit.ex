defmodule FactorAudit do
  def main(args) do
    # Need to call get_user_list and then
    # pass that to a function that pulls information
    # for each user.
    {:ok, users} = UserList.new


    {options, [org_name], _} = OptionParser.parse(args, aliases: [w: :whitelist])

    IO.puts "Looking for users in #{org_name} org that do not have two factor authentication enabled"

    
    if filename = Keyword.get(options, :whitelist) do
      go_get_users(make_url(org_name), users, WhiteList.read(filename))
    else
      go_get_users(make_url(org_name), users)
    end



    :timer.sleep(1000)
    UserList.get(users) |> Enum.each(fn(x) -> IO.puts("#{elem(x, 0)}, #{elem(x, 1)}, #{elem(x, 2)}") end)
    IO.puts "Found #{length(UserList.get(users))} users with 2fa disabled that weren't on the whitelist"
  end

  defp go_get_users(url, user_list, whitelist \\ []) do
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
        # IO.puts "got next page #{next_link}"
        go_get_users(next_link, user_list, whitelist)
      _ ->
        {:done}
    end
  end

  def make_url(org_name) do
    "https://api.github.com/orgs/" <> org_name <> "/members?filter=2fa_disabled"
  end

  def get_next_link(headers) do
    case Keyword.fetch(headers, :"Link") do
      :error -> {:error, :nolink}
      {:ok, string_of_links} -> next_extractor(string_of_links)
    end
  end

  def next_extractor(string_of_links) do
    links = string_of_links
    |> String.split(",")
    |> Enum.map(fn(x) -> String.split(x) |> List.to_tuple end)
    |> Enum.filter(fn(x) -> elem(x,1) == "rel=\"next\"" end)

    case links do
      [] -> {:error, :nolink}
      [final_link_string] -> final_link_string |> elem(0) |> url_extractor
      _ -> {:error, :nolink}
    end
  end

  def url_extractor(link_string) do
    finished = link_string
    |> String.split(["<",">"])
    |> Enum.filter(fn(x) -> String.starts_with?(x, "https") end)
    |> hd
    {:ok, finished}
  end
end

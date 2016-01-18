defmodule FactorAudit do
  def main do
    # Need to call get_user_list and then
    # pass that to a function that pulls information
    # for each user.
    get_user_list("heroku") |> Enum.each(fn(x) -> IO.puts x end)
  end

  defp get_user_list(orgName) do
    base_url = "https://api.github.com/orgs/"
    final_url = base_url <> orgName <> "/members?filter=2fa_disabled"
    get_user_list(orgName, final_url)
  end

  defp get_user_list(_, url) do

    headers = ["User-Agent": "Elixir",
      "Content-Type": "application/json",
      "Authorization": "token #{System.get_env("GITHUB_API_KEY")}"]

    all_users = []

    response = HTTPotion.get url, [headers: headers]

    case Poison.Parser.parse(response.body) do
      {:ok, json} ->
        all_users = json |> Enum.reduce all_users, fn(x, all_users) ->
          all_users = [x["login"]|all_users]
        end
      _ ->
    end
    all_users
  end

end

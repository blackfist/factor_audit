defmodule Anus do
  def main do
    headers = ["User-Agent": "Elixir",
      "Content-Type": "application/json",
      "Authorization": "token #{System.get_env("GITHUB_API_KEY")}"]
    response = HTTPotion.get "https://api.github.com/orgs/heroku/members", [headers: headers]
    [H|T] = response.headers
    IO.puts "I got #{H}"
    get_link(response.headers)
  end

  def get_link([H|T]) do
    IO.puts "#{H} is not what I'm looking for."
    get_link(T)
  end
  def get_link([]), do: :done
end

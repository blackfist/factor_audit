defmodule UserList do
  use GenServer

  def new() do
    GenServer.start_link(__MODULE__, [])
  end

  def add(pid, value) do
    GenServer.cast(pid, {:enrich, value})
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def handle_cast({:enrich, value}, state) do
    Task.async fn ->
      headers = ["User-Agent": "Elixir",
        "Content-Type": "application/json",
        "Authorization": "token #{System.get_env("GITHUB_API_KEY")}"]

      url = "https://api.github.com/users/" <> value

      response = HTTPotion.get url, [headers: headers]
      user_data = response.body |> Poison.Parser.parse!


      name = Map.get(user_data, "name") || "No public name"
      email = Map.get(user_data, "email") || "No public email"
      {:update, {value, name, email}}
    end
    {:noreply, state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_info({ref, {:update, value}}, state) when is_reference(ref) do
    {:noreply, [value | state]}
  end

  def handle_info(_, state), do: {:noreply, state}
end

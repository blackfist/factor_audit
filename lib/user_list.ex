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

      # Why didn't I use Map.get/3 here? Well this threw me for a while.
      # Turns out the response from GitHub will have these fields defined
      # as nil. So I was using Map.get/3 and still getting nil and I was
      # like "WTF?"
      name = Map.get(user_data, "name") || "No public name"
      email = Map.get(user_data, "email") || "No public email"

      # When a task ends, it automatically sends an info message
      # this next line is handled by a handle_info
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

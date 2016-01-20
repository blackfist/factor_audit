defmodule WhiteList do
  def read(filename) do
    File.stream!(filename) |>
      Enum.filter(fn(x) -> !String.starts_with?(x, ["\n","#"]) end) |>
      Enum.map(fn(x) -> String.strip(x) end)
  end

end

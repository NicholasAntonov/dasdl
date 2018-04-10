defmodule Dasdl do
  @moduledoc """
  Documentation for Rip.
  """

  @doc """
  Hello world.

  ## Examples

  iex> Dasdl.hello
  :world

  """
  def rip do
    url = "https://www.destroyallsoftware.com/screencasts/catalog"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Floki.find(body, ".episode a")
        |> Floki.attribute("href")
        |> Enum.map(fn cast_path ->
          title = getTitle cast_path
          IO.puts "https://www.destroyallsoftware.com/screencasts/catalog/#{title}/download?resolution=1080p"
          dl("https://www.destroyallsoftware.com/screencasts/catalog/#{title}/download?resolution=1080p", title)
        end)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
    :world
  end

  def dl(cast_url, name) do
    case HTTPoison.get(cast_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        dl_path = "das/#{name}.mp4"

        dl_path
        |> removeLast
        |> File.mkdir_p!

        File.write!(dl_path, body)
      {:ok, %HTTPoison.Response{status_code: 302, body: body}} ->
        Floki.find(body, "a")
        |> Floki.attribute("href")
        |> Enum.map(fn cast_path ->
          IO.puts cast_path
          dl(cast_path, name)
        end)
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        IO.puts "Non 200 response: error #{code}"
        IO.inspect body
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def getTitle(url) do
    parts = String.splitter(url, "/", trim: true)
    Enum.at(parts, -1)
  end

  def removeLast(path) do
    {_, rest} = String.splitter(path, "/") |> Enum.to_list |> List.pop_at(-1)
    Enum.join(rest, "/")
  end
end

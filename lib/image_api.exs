defmodule ImageApi do
  @url "https://api.myjson.com/bins/"
  def query(data) do
    HTTPoison.get("#{@url}#{data}")
    |> handle_request
  end


  def handle_request({:error, %HTTPoison.Error{id: nil,reason: :econnrefused}}) do
    {:error, :econnrefused}
  end

  def handle_request({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
  
  def handle_request({:ok, response}) do
    {:ok, Poison.Parser.parse!(response.body)
    |> get_in(["image","image_url"])}
  end
end


case ImageApi.query("16x3i5") do
    {:ok, image_url} ->
      image_url
    {:error, error} ->
      "Whoops! #{error}"
end

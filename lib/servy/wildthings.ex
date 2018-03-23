defmodule Servy.Wildthings do
  require Logger
  alias Servy.Bear

  @db_path Path.expand("../../db", __DIR__)

  def list_bears do
    @db_path
    |> Path.join("bears.json")
    |> read_json
    |> Poison.decode!(as: %{"bears" => [%Bear{}]})
    |> Map.get("bears")
  end

  def read_json(source) do
    case File.read(source) do
      {:ok, contents} ->
        contents

      {:error, reason} ->
        Logger.error("Error reading #{source}: #{reason}")
        "[]"
    end
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn b -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id
    |> String.to_integer()
    |> get_bear
  end
end

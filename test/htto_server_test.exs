defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "accepts a request on a socket and sends back a response" do
    spawn(HttpServer, :start, [4000])

    parent = self

    Enum.each(1..5, fn n ->
      spawn(fn -> send(parent, HTTPoison.get("http://localhost:4000/wildthings")) end)
    end)

    Enum.each(1..5, fn n ->
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body == "Bears, Lions, Tigers"
      end
    end)
  end
end

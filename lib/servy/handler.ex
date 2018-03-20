defmodule Servy.Handler do
  @moduledoc """
  Handled HTTP request
  """

  alias Servy.Conv

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1, emojify: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc """
  Transforms the request into a response
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> emojify
    |> format_response
  end

  def route(conv = %Conv{method: "GET", path: "/wildthings"}) do
    %Conv{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(conv = %Conv{method: "GET", path: "/bears/new", resp_body: _}) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(conv = %Conv{method: "GET", path: "/bears/" <> id, resp_body: _}) do
    %{conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(conv = %Conv{method: "GET", path: "/bears", resp_body: _}) do
    %{conv | resp_body: "Yogy, Pands, Winnie", status: 200}
  end

  def route(conv = %Conv{ method: "DELETE", path: "/bears" }) do
    %{conv | resp_body: "Bears must never be deleted", status: 403 } 
  end

  def route(conv = %{ method: "GET", path: "/about"}) do
    Path.expand("../../pages", __DIR__)
    |> Path.join(".#{conv.path}.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(conv = %Conv{ method: "GET", path: "/pages/" <> id}) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("#{id}.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(conv = %Conv{ method: "POST", path: "/bears"}) do
    %Conv{ conv | status: 201, resp_body: "Create a bear named #{conv.params["name"]} type #{conv.params["type"]}" }
  end

  def route(%Conv{} = conv) do
    %{conv | resp_body: " #{conv.path} Not found", status: 404}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)} 
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)} 

    #{conv.resp_body} 
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)


request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
response = Servy.Handler.handle(request)

IO.puts(response)


request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""
response = Servy.Handler.handle(request)

IO.puts(response)


request = """
POST /bears HTTP/1.1
User_Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: Application/x-ww-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)

IO.puts(response)

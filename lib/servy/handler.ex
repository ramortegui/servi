defmodule Servy.Handler do
  @moduledoc """
  Handled HTTP request
  """

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

  def route(conv = %{method: "GET", path: "/wildthings"}) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(conv = %{method: "GET", path: "/bears/new" <> id, resp_body: _}) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(conv = %{method: "GET", path: "/bears/" <> id, resp_body: _}) do
    %{conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(conv = %{method: "GET", path: "/bears", resp_body: _}) do
    %{conv | resp_body: "Yogy, Pands, Winnie", status: 200}
  end

  def route(conv = %{ method: "DELETE", path: "/bears" }) do
    %{conv | resp_body: "Bears must never be deleted", status: 403 } 
  end

  def route(conv = %{ method: "GET", path: "/about"}) do
    Path.expand("../../pages", __DIR__)
    |> Path.join(".#{conv.path}.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(conv = %{ method: "GET", path: "/pages/" <> id}) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("#{id}.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(conv) do
    %{conv | resp_body: " #{conv.path} Not found", status: 404}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)} 
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)} 

    #{conv.resp_body} 
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Interal Server Error"
    }[code]
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

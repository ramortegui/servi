defmodule Servy.Handler do
  @moduledoc """
  Handled HTTP request
  """

  @pages_path Path.expand("../../pages", __DIR__)

  require Logger

  @doc """
  Transforms the request into a response
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> route
    |> track
    |> emojify
    |> log
    |> format_response
  end


  def emojify(conv = %{ status: 200, resp_body: resp_body }) do
    emoji = """
                   ∩
    　⚡️　　　　　＼＼
    　　　　　　　／　 ）
    ⊂＼＿／￣￣￣　 ／
    　＼＿／   ° ͜ʖ ° （
    　　　）　　 　／⌒＼
    　　／　 ＿＿＿／⌒＼⊃
    　（　 ／
    　　＼＼
          U

    """
    %{ conv | resp_body:  emoji <> resp_body}
  end
  
  def emojify(conv), do: conv

  @doc "Logs 404 request"
  def track(conv = %{ status: 404, path: path }) do
    IO.puts "Warning: #{path} is on the loose!"
    conv
  end

  def track(conv), do: conv

  def parse(request) do
    [method, path, _version] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split()

    %{
      method: method,
      path: path,
      status: nil,
      resp_body: ""
    }
  end

  def log(conv) do
    Logger.debug( 
      fn() -> "Solving #{conv.path} status #{conv.status}" end
    )
    conv
  end

  def rewrite_path(conv = %{ path: "/wildlife" }) do
    %{conv | path: "/wildthings"}
  end
  
  def rewrite_path(conv = %{ path: path }) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}"}
  end
  def rewrite_path_captures(conv, nil), do: conv

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

  def handle_file({:ok, content}, conv) do
    %{conv | resp_body: content, status: 200}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | resp_body: "File not found", status: 404}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | resp_body: "File error: #{reason}", status: 500}
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

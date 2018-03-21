defmodule Servy.Handler do
  @moduledoc """
  Handled HTTP request
  """

  alias Servy.Conv
  alias Servy.BearController

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
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(conv = %Conv{method: "GET", path: "/bears", resp_body: _}) do
    BearController.index(conv)
  end

  def route(conv = %Conv{ method: "DELETE", path: "/bears" }) do
    BearController.delete(conv, conv.params)
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
    BearController.create(conv, conv.params)
  end

  def route(%Conv{} = conv) do
    %{conv | resp_body: " #{conv.path} Not found", status: 404}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: text/html\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end

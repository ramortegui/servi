defmodule Servy.Handler do
  @moduledoc """
  Handled HTTP request
  """

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam
  alias Servy.Fetcher

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
    #  |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route( %Conv{ method: "GET", path: "/sensors" } = conv) do
    pid1 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-1") end)
    pid2 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-1") end)
    pid3 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-1") end)
    pid4 = Fetcher.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshot1 = Fetcher.get_result(pid1) 
    snapshot2 = Fetcher.get_result(pid2)
    snapshot3 = Fetcher.get_result(pid3)
    where_is_bigfoot = Fetcher.get_result(pid4)

    snapshots = [snapshot1, snapshot2, inspect { snapshot3, where_is_bigfoot }]

    %{conv | status: 200, resp_body: inspect snapshots }
  end

  def route(conv = %Conv{method: "GET", path: "/wildthings"}) do
    %Conv{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(conv = %Conv{method: "GET", path: "/hibernate/" <> time}) do
    time
    |> String.to_integer
    |> :timer.sleep
    %Conv{conv | resp_body: "Awake!!!", status: 200}
  end

  def route(conv = %Conv{method: "GET", path: "/kaboom"}) do
    raise "'KABOOM!!!"
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

  def route(conv = %Conv{method: "GET", path: "/api/bears", resp_body: _}) do
    Servy.Api.BearController.index(conv)
  end

  def route(conv = %Conv{ method: "POST", path: "/api/bears"}) do
    Servy.Api.BearController.create(conv)
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

  def route(conv = %Conv{ method: "GET", path: "/pages/faq" <> id}) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("#{id}.md")
    |> File.read
    |> handle_file(conv)
    |> parse_md

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
    Content-Type: #{conv.resp_headers["Content-Type"]}\r
    Content-Length: #{conv.resp_headers["Content-Length"]}\r
    \r
    #{conv.resp_body}
    """
  end

  defp parse_md(%Conv{status: 200} = conv) do
    %{ conv | resp_body: Earmark.as_html(conv.resp_body)}
  end

  defp parse_md(%Conv{} = conv), do: conv

  def put_content_length(%Conv{} = conv) do
    resp_headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{ conv | resp_headers: resp_headers }
  end
end

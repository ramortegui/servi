defmodule Servy.Parser do
  alias Servy.Conv
  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _version] = String.split(request_line, " ")

    headers = reduce_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      status: nil,
      resp_body: "",
      params: params
    }
  end

  def parse_params("Application/x-ww-form-urlencoded", params_string) do
    params_string
    |> String.trim
    |> URI.decode_query
  end

  def parse_params(_ , params_string) do
    params_string
    |> String.trim
    |> URI.decode_query
  end

  def reduce_headers(headers) do
    Enum.reduce(headers, %{},
                fn(line, headers_so_far) -> 
                  [key, value] = String.split(line, ": ")
                  Map.put(headers_so_far, key, value)
                end
    )
  end

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers) do
    headers
  end
end

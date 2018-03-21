defmodule Servy.Parser do
  alias Servy.Conv
  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\r\n")

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

  @doc """
  Parses the fiben param stirng of th eform `key=value1&key2=value2``
  into a map with corresponding keys and values

  ## Examples
      iex> params_string = "name=Baloo&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Baloo", "type" => "Brown"} 
      iex> Servy.Parser.parse_params("multipar/from-data", params_string)
      %{} 

  """

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim
    |> URI.decode_query
  end

  def parse_params("application/json", params_string) do
    params_string
    |> String.trim
    |> Poison.Parser.parse! 
  end

  def parse_params(_ , params_string) do
    %{}
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

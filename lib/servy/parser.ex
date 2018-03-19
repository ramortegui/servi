defmodule Servy.Parser do
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
end

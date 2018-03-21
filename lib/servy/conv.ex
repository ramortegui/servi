defmodule Servy.Conv do
  alias Servy.Conv
  defstruct method: "",
  path: "",
  resp_body: "",
  status: nil,
  params: %{},
  headers: %{},
  resp_headers: %{ "Content-Type" => "text/html" }

  def full_status(%Conv{} = conv) do
    "#{conv.status} #{status_reason(conv.status)}"
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

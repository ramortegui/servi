defmodule Servy.FileHandler do
  alias Servy.Conv
  def handle_file({:ok, content}, %Conv{} = conv) do
    %Conv{conv | resp_body: content, status: 200}
  end

  def handle_file({:error, :enoent}, %Conv{} = conv) do
    %Conv{conv | resp_body: "File not found", status: 404}
  end

  def handle_file({:error, reason}, %Conv{} = conv) do
    %Conv{conv | resp_body: "File error: #{reason}", status: 500}
  end

end

defmodule Servy.FileHandler do
  def handle_file({:ok, content}, conv) do
    %{conv | resp_body: content, status: 200}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | resp_body: "File not found", status: 404}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | resp_body: "File error: #{reason}", status: 500}
  end

end

defmodule Servy.Plugins do
  require Logger

  alias Servy.Conv

  @doc "Logs 404 request"
  def track(conv = %{ status: 404, path: path }) do
    if Mix.env != :test do
      IO.puts "Warning: #{path} is on the loose!"
    end
    conv
  end

  def track(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      Logger.debug( 
        fn() -> "Solving #{conv.path} status #{conv.status}" end
      )
    end
    conv
  end

  def rewrite_path(conv = %Conv{ path: "/wildlife" }) do
    %{conv | path: "/wildthings"}
  end
  
  def rewrite_path(conv = %Conv{ path: path }) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(conv, nil), do: conv
  
  def emojify(conv = %Conv{ status: 200, resp_body: resp_body }) do
    emoji = """
    ⚡️
    """
    %Conv{ conv | resp_body:  emoji <> resp_body}
  end
  
  def emojify(%Conv{} = conv), do: conv
end


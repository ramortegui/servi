defmodule Servy.Plugins do
  require Logger

  @doc "Logs 404 request"
  def track(conv = %{ status: 404, path: path }) do
    IO.puts "Warning: #{path} is on the loose!"
    conv
  end

  def track(conv), do: conv

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
end


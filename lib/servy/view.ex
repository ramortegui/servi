defmodule Servy.View do
  @templates_path Path.expand("../../templates", __DIR__)
  def render(conv, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{conv | resp_body: content, status: 200}
  end
end

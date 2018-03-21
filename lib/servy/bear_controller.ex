defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear

  @templates_path Path.expand("../../templates", __DIR__)
  
  def index(conv) do
    bears = Wildthings.list_bears()
            |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{ "id" => id }) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  defp render(conv, template, bindings \\ []) do
    content = 
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)
      %{conv | resp_body: content, status: 200}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201, resp_body: "Create a bear named #{name} type #{type}" }
  end

  def delete(conv, _params) do
    %{conv | resp_body: "Bears must never be deleted", status: 403 } 
  end
end

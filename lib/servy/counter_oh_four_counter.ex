defmodule Servy.FourOhFourCounter do
  @name __MODULE__
  def start() do
    {:ok, agent} = Agent.start(fn -> %{} end) 
    Process.register(agent, @name)
  end

  def bump_count(name) do
    Agent.update(@name,
                 fn(state) -> 
                   new_state = case Map.get(state, name)  do
                     nil -> Map.put(state,name,1)
                     count -> Map.put(state, name, count + 1)
                   end
                   new_state 
                 end)
  end

  def get_count(name) do
    Agent.get(@name,
              fn(state) -> 
                case Map.get(state,name) do
                  nil -> 0
                  count -> count
                end
              end)
  end

  def get_counts do
    Agent.get(@name,
              fn(state) ->
                state
              end)
  end
end

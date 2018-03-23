defmodule Servy.PledgeServer do
  @name :pledge_server
  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  def start do
    IO.puts "Starting the Generic server..."
    GenServer.start(__MODULE__, %State{} , name: @name)
  end

  def init(state) do
    pledges = fetch_recent_pledges_from_service()

    {:ok, %{ state | pledges: pledges } }
  end

  def set_cached_size(size) do
    GenServer.cast @name, {:set_cast_size, size }
  end

  def create_pledge(name, amount) do
    {:ok, id} = send_pledge_to_service(name, amount)
    GenServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges do
    GenServer.call @name,:recent_pledges
  end

  def total_pledged do
    GenServer.call @name,:total_pledges
  end

  def clear do
    GenServer.cast @name,:clear
  end

  def handle_cast(:clear, state) do
    {:noreply, %State{}}
  end

  def handle_case({:set_cache_size, size}, state) do
    {:noreply, %{ state | cache_size: size }}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &(elem(&1,1)) ) |> Enum.sum
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    catched_pledges = [ {name, amount } | most_recent_pledges]
    new_state = %{state | pledges: catched_pledges}
    {:reply, id , new_state}
  end

  def handle_info(message, state) do
    IO.puts "Can't touch this #{inspect message}"
    {:reply, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # code to send pledge to external service

    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    [{"wilma", 15}, {"fred", 25}]
  end
end

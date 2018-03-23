defmodule Servy.SensorServer do
  @name :sensor_server

  use GenServer

  alias Servy.VideoCam

  defmodule State do
    defstruct sensor_data: %{},
              refresh_interval: :timer.minutes(60)
  end

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  def set_refresh_interval(time) do
    GenServer.cast(@name, {:set_refresh_interval, time})
  end

  def init(_state) do
    initial_state = run_tasks_to_get_sensor_data()
    state = %State{sensor_data: initial_state}
    schedule_refresh(state.refresh_interval)
    {:ok, state}
  end

  def handle_cast({:set_refresh_interval, time}, state) do
    new_state = %{state | refresh_interval: time}
    schedule_refresh(time)
    {:noreply, new_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh, state) do
    new_state = %{state | sensor_data: run_tasks_to_get_sensor_data()}
    schedule_refresh(new_state.refresh_interval)
    {:noreply, new_state}
  end

  defp schedule_refresh(refresh_interval) do
    Process.send_after(self(), :refresh, refresh_interval)
  end

  defp run_tasks_to_get_sensor_data do
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam1", "cam2", "cam3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end

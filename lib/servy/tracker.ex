defmodule Servy.Tracker do

  def get_location(wildthing) do
    :timer.sleep(500)
    
    locations = %{
      "roscoe" => %{ lat: "44.123N", lng: "121.233 W"},
      "smokey" => %{ lat: "45.123N", lng: "122.23 W"},
      "brutus" => %{ lat: "46.123N", lng: "123.23 W"},
      "bigfoot" => %{ lat: "47.123N", lng: "124.23 W"} 
    }

    Map.get(locations, wildthing)
  end
end

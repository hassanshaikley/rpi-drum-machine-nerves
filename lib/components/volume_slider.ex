defmodule RpiDrumMachineNerves.Components.VolumeSlider do
  @moduledoc """
  Volume Slider component
  """

  use Scenic.Scene, has_children: false
  import Scenic.Components
  import Scenic.Primitives
  import Scenic.Components

  def add_to_graph(graph, _data \\ nil, _opts \\ []) do
    graph
    |> group(
      fn graph ->
        graph
        |> text("volume", translate: {450, 112})
        |> slider({{40, 100}, 50},
          id: :volume_slider,
          translate: {500, 100},
          width: 100
        )
      end,
      t: {0, 0}
    )
  end

  def info(_data) do
  end

  def verify(_any) do
  end
end

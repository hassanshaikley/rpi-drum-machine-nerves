defmodule DrumMachineNerves.Components.VolumeSlider do
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
        |> text("volume")
        |> button("+",
          theme: %{
            text: :white,
            background: {100, 100, 100},
            active: {100, 200, 100},
            border: :green
          },
          id: :volume_up,
          t: {0, 10},
          height: 40,
          width: 40
        )
        |> button("-",
          theme: %{
            text: :white,
            background: {100, 100, 100},
            active: {100, 200, 100},
            border: :green
          },
          id: :volume_down,
          t: {50, 10},
          height: 40,
          width: 40
        )
      end,
      t: {450, 30}
    )
  end

  def info(_data) do
  end

  def verify(_any) do
  end
end

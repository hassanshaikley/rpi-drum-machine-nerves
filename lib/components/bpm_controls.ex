defmodule DrumMachineNerves.Components.BpmControls do
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
        |> text("bpm (90)", id: :bpm_label)
        |> button("+",
          theme: %{
            text: :white,
            background: {100, 100, 100},
            active: {100, 200, 100},
            border: :green
          },
          id: :increase_bpm,
          t: {60, -17},
          height: 70,
          width: 70
        )
        |> button("-",
          theme: %{
            text: :white,
            background: {100, 100, 100},
            active: {100, 200, 100},
            border: :green
          },
          id: :decrease_bpm,
          t: {140, -17},
          height: 70,
          width: 70
        )
      end,
      t: {150, 30}
    )
  end

  def info(_data) do
  end

  def verify(_any) do
  end
end

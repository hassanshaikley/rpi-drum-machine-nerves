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
          id: :decrease_bpm,
          t: {50, 10},
          height: 40,
          width: 40
        )
      end,
      t: {200, 30}
    )
  end

  def info(_data) do
  end

  def verify(_any) do
  end
end

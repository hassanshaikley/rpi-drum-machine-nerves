defmodule RpiDrumMachineNerves.Component.Header do
  use Scenic.Scene, has_children: false
  import Scenic.Components
  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components

  def add_to_graph(graph, data \\ nil, opts \\ []) do
    graph
    |> group(
      fn graph ->
        graph
        |> rect({780, 75},
          fill: :dark_gray,
          translate: {0, 0}
        )
        |> text("Nerves Drum Machine",
          id: :pos,
          translate: {630, 60},
          font_size: 16,
          fill: :black
        )
      end,
      id: :header,
      t: {10, 10}
    )
  end

  def info(data) do
  end

  def verify(any) do
  end
end
defmodule DrumMachineNerves.Components.Header do
  @moduledoc """
  Header component
  """
  use Scenic.Scene, has_children: false
  import Scenic.Primitives

  def add_to_graph(graph, _data \\ nil, _opts \\ []) do
    graph
    |> group(
      fn graph ->
        graph
        |> rect({780, 75},
          fill: :dark_gray,
          translate: {0, 0}
        )
        |> text(">><<",
          id: :debug,
          translate: {30, 60},
          font_size: 16,
          fill: :black
        )
        |> text("#{Mix.env()}",
          translate: {30, 70},
          fill: :black
        )
      end,
      id: :header,
      t: {10, 10}
    )
  end
end

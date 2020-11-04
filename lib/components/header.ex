defmodule RpiDrumMachineNerves.Components.Header do
  use Scenic.Component, has_children: false
  alias Scenic.{Graph, Primitives}

  @graph Graph.build(font: :roboto_mono, font_size: 30)
         |> Primitives.group(
           fn graph ->
             graph
             |> Primitives.rect({780, 75}, fill: :dark_gray, translate: {0, 0})
             |> Primitives.text("RPI Drum Machine Nerves", translate: {380, 70}, fill: :black)
             |> Primitives.text("v 1.0", translate: {730, 70}, font_size: 16, fill: :black)
           end,
           id: :header,
           t: {10, 10}
         )

  def init(_, _opts), do: {:ok, %{}, push: @graph}

  def verify(_), do: {:ok, nil}
end

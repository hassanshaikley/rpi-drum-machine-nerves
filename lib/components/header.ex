defmodule RpiDrumMachineNerves.Components.Header do
  @moduledoc """
  Header component
  """
  use Scenic.Component, has_children: false
  import Scenic.Primitives

  alias Scenic.Graph

  @graph Graph.build(font: :roboto_mono, font_size: 30)
         |> group(
           fn graph ->
             graph
             |> rect({780, 75},
               fill: :dark_gray,
               translate: {0, 0}
             )
             |> text("RPI Drum Machine Nerves",
               id: :title,
               translate: {380, 70},
               font_size: 30,
               fill: :black
             )
             |> text("v 1.0",
               id: :title,
               translate: {730, 70},
               font_size: 16,
               fill: :black
             )
           end,
           id: :header,
           t: {10, 10}
         )

  def init(_, _opts) do
    graph = @graph

    {:ok, %{}, push: graph}
  end

  def verify(_), do: {:ok, nil}
end

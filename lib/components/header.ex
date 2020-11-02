defmodule RpiDrumMachineNerves.Components.Header do
  @moduledoc """
  Header component
  """
  use Scenic.Component, has_children: false
  import Scenic.Primitives

  alias Scenic.Graph

  @graph Graph.build()
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

  def init(_, _opts) do
    graph = @graph

    {:ok, %{}, push: graph}
  end

  def verify(_), do: {:ok, nil}
end

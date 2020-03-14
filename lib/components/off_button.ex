defmodule RpiDrumMachineNerves.Component.OffButton do
  use Scenic.Scene, has_children: false
  import Scenic.Components
  import Scenic.Primitives
  import Scenic.Components

  def add_to_graph(graph, data \\ nil, opts \\ []) do
    graph
    |> button("OFF",
      theme: %{
        text: :white,
        background: :black,
        active: :black,
        border: :green
      },
      id: "shutdown",
      translate: {700, 100},
      height: 50,
      width: 50
    )
  end

  def info(_data) do
  end

  def verify(_any) do
  end
end

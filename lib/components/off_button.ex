defmodule DrumMachineNerves.Components.OffButton do
  @moduledoc """
  Shutdown button component
  """

  use Scenic.Scene, has_children: false
  import Scenic.Components

  def add_to_graph(graph, _data \\ nil, _opts \\ []) do
    graph
    |> button("OFF",
      theme: %{
        text: :white,
        background: :red,
        active: :black,
        border: :green
      },
      id: :poweroff,
      translate: {700, 13},
      height: 70,
      width: 70
    )
  end
end

defmodule RpiDrumMachineNerves.Components.OffButton do
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
        background: :black,
        active: :black,
        border: :green
      },
      id: "shutdown",
      translate: {400, 50},
      height: 50,
      width: 50
    )
  end

  def info(_data) do
  end

  def verify(_any) do
  end
end

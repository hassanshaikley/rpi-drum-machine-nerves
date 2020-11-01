defmodule DrumMachineNerves.Components.VolumeControls do
  @moduledoc """
  Volume Slider component
  """

  use Scenic.Component, has_children: true
  import Scenic.Components
  import Scenic.Primitives
  import Scenic.Components

  alias Scenic.Graph

  @graph Graph.build()
         |> group(
           fn graph ->
             graph
             |> text("volume (50)", t: {-17, 0}, id: :volume_label)
             |> button("+",
               theme: %{
                 text: :white,
                 background: {100, 100, 100},
                 active: {100, 200, 100},
                 border: :green
               },
               id: :volume_up,
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
               id: :volume_down,
               t: {140, -17},
               height: 70,
               width: 70
             )
           end,
           t: {450, 30}
         )

  def init(_, _opts) do
    state = %{
      graph: @graph
    }

    {:ok, state, push: state.graph}
  end

  def verify(_), do: {:ok, nil}
end

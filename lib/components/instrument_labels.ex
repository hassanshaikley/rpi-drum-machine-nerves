defmodule RpiDrumMachineNerves.Components.InstrumentLabels do
  use Scenic.Component, has_children: false

  import Scenic.Primitives

  alias Scenic.Graph

  @graph Graph.build(font: :roboto_mono, font_size: 16)
         |> group(
           fn graph ->
             graph
             |> text("hihat", t: {0, 0}, id: :volume_label)
             |> text("snare", t: {0, 64}, id: :volume_label)
             |> text("cymbal", t: {0, 64 * 2}, id: :volume_label)
             |> text("kick", t: {0, 64 * 3}, id: :volume_label)
             |> text("tom", t: {0, 64 * 4}, id: :volume_label)
           end,
           t: {10, 150}
         )

  def init(
        _,
        _opts
      ) do
    graph = @graph

    state = %{
      graph: graph
    }

    {:ok, state, push: graph}
  end

  def verify(_), do: {:ok, nil}
end

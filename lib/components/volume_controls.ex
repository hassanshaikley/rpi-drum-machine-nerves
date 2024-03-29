defmodule RpiDrumMachineNerves.Components.VolumeControls do
  @moduledoc """
  Volume Slider component
  """

  use Scenic.Component, has_children: true
  import Scenic.{Components, Primitives}

  alias Scenic.Graph

  @graph Graph.build(font: :roboto_mono, font_size: 16)
         |> group(
           fn graph ->
             graph
             |> text("vol", t: {0, 0})
             |> text("50", t: {0, 13}, id: :volume_label)
             |> button("+",
               theme: %{
                 text: :white,
                 background: {100, 100, 100},
                 active: {100, 200, 100},
                 border: :black
               },
               id: :volume_up,
               t: {40, -10},
               height: 70,
               width: 70
             )
             |> button("-",
               theme: %{
                 text: :white,
                 background: {100, 100, 100},
                 active: {100, 200, 100},
                 border: :black
               },
               id: :volume_down,
               t: {40, -10 + 80},
               height: 70,
               width: 70
             )
           end,
           t: {630, 300}
         )

  def init(_, _opts) do
    state = %{
      graph: @graph
    }

    {:ok, state, push: state.graph}
  end

  def verify(_), do: {:ok, nil}

  def handle_cast({:update_volume, new_volume}, state) do
    vol = Integer.to_string(new_volume)
    graph = Graph.modify(state.graph, :volume_label, &text(&1, vol))
    {:noreply, state, push: graph}
  end

  def child_spec({args, opts}) do
    %{
      id: make_ref(),
      start:
        {Scenic.Scene, :start_link, [__MODULE__, args, Keyword.put_new(opts, :name, __MODULE__)]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end

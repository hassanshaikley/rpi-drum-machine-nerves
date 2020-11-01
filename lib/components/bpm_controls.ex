defmodule DrumMachineNerves.Components.BpmControls do
  @moduledoc """
  Volume Slider component
  """

  use Scenic.Component, has_children: true
  import Scenic.Components
  import Scenic.Primitives
  import Scenic.Components

  alias Scenic.Graph

  @graph Graph.build(font: :roboto, font_size: 16)
         |> group(
           fn graph ->
             graph
             |> text("bpm (90)", id: :bpm_label)
             |> button("+",
               theme: %{
                 text: :white,
                 background: {100, 100, 100},
                 active: {100, 200, 100},
                 border: :green
               },
               id: :increase_bpm,
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
               id: :decrease_bpm,
               t: {140, -17},
               height: 70,
               width: 70
             )
           end,
           t: {150, 30}
         )

  def init(_, _opts) do
    graph = @graph
    {:ok, %{graph: graph}, push: graph}
  end

  def verify(_), do: {:ok, nil}

  def filter_event({:click, :decrease_bpm} = event, _context, state) do
    {:cont, event, state, push: state.graph}
  end

  def filter_event({:click, :increase_bpm} = event, _context, state) do
    {:cont, event, state, push: state.graph}
  end

  def handle_cast({:update_bpm, new_bpm}, state) do
    graph =
      Graph.modify(
        state.graph,
        :bpm_label,
        &text(&1, "bpm (" <> Integer.to_string(new_bpm) <> ")")
      )

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

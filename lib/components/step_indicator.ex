defmodule DrumMachineNerves.Components.StepIndicator do
  use Scenic.Component, has_children: false
  import Scenic.Primitives

  alias Scenic.{Graph, Primitive}
  alias DrumMachineNerves.Optimizations

  @graph Graph.build()
         |> group(
           fn graph ->
             Enum.map(0..(8 - 1), fn col ->
               {(60 + 4) * col, 4, col}
             end)
             |> Enum.reduce(
               graph,
               fn obj, graph ->
                 x = elem(obj, 0)
                 y = elem(obj, 1)
                 index = elem(obj, 2)

                 graph
                 |> rect({60, 10},
                   fill: :red,
                   translate: {x, y},
                   id: {index, :h}
                 )
               end
             )
           end,
           t: {16, 120}
         )

  def verify(_), do: {:ok, nil}

  def init(_text, _opts) do
    graph = @graph

    state = %{
      graph: graph
    }

    {:ok, state, push: graph}
  end

  def handle_cast({:loop, iteration}, state) do
    graph = update(state.graph, iteration)
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

  defp update(state, iteration) do
    state
    |> Graph.modify({iteration, :h}, fn p ->
      Primitive.put_style(p, :fill, :blue)
    end)
    |> Graph.modify({Optimizations.get_previous_iteration(iteration), :h}, fn p ->
      Primitive.put_style(p, :fill, :red)
    end)
  end
end

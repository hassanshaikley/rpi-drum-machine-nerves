defmodule DrumMachineNerves.Components.StepIndicator do
  use Scenic.Component, has_children: false
  import Scenic.Primitives

  alias Scenic.Graph

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
    # modify the already built graph
    graph = @graph
    #   |> Graph.modify(:_root_, &update_opts(&1, styles: opts[:styles]))
    #   |> Graph.modify(:text, &text(&1, text))

    state = %{
      graph: graph,
      text: "hi",
      name: __MODULE__,
      id: __MODULE__
    }

    IO.puts("init step indicator")

    {:ok, state, push: graph}
  end

  # Not quite working how I want yet
  def handle_info(:loop, state) do
    IO.puts("Looping")
    graph = @graph
    {:ok, state, push: graph}
  end
end

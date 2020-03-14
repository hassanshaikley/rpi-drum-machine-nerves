defmodule RpiDrumMachineNerves.Component.StepIndicator do
  use Scenic.Scene, has_children: false
  import Scenic.Primitives

  def add_to_graph(
        graph,
        _data \\ nil,
        [button_width: button_width, button_padding: button_padding, num_cols: num_cols] = _opts
      ) do
    graph
    |> group(
      fn graph ->
        Enum.map(0..(num_cols - 1), fn col ->
          {(button_width + button_padding) * col, button_padding, Integer.to_string(col)}
        end)
        |> Enum.reduce(
          graph,
          fn obj, graph ->
            x = elem(obj, 0)
            y = elem(obj, 1)
            index = elem(obj, 2)

            graph
            |> rect({button_width, 10},
              fill: :red,
              translate: {x, y},
              id: "#{index}_h"
            )
          end
        )
      end,
      t: {16, 160}
    )
  end

  def info(_data) do
  end

  def verify(_any) do
  end
end

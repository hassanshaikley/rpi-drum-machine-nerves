defmodule DrumMachineNerves.Components.PushButtons do
  @moduledoc """
  Push Buttons component
  """

  use Scenic.Scene, has_children: false
  import Scenic.{Components, Primitives}

  def add_to_graph(
        graph,
        _data \\ nil,
        [button_width: button_width, button_height: button_height, buttons: buttons] = _opts
      ) do
    graph
    |> group(
      fn graph ->
        Enum.reduce(
          buttons,
          graph,
          fn obj, graph ->
            graph
            |> push_button(obj, button_width, button_height, :up, {200, 200, 200})
            |> push_button(obj, button_width, button_height, :down, {50, 240, 50})
          end
        )
      end,
      t: {16, 140}
    )
  end

  defp push_button(graph, obj, button_width, button_height, direction, background) do
    x = elem(obj, 0)
    y = elem(obj, 1)
    label = elem(obj, 2)
    id = Tuple.append(label, direction)
    hidden = direction == :down

    button(graph, "",
      theme: %{
        text: :white,
        background: background,
        active: background,
        border: :green
      },
      hidden: hidden,
      id: id,
      translate: {x, y},
      height: button_height,
      width: button_width
    )
  end
end

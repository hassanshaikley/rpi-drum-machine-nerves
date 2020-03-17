defmodule RpiDrumMachineNerves.Components.PushButtons do
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
            x = elem(obj, 0)
            y = elem(obj, 1)
            label = elem(obj, 2)

            graph
            |> button("",
              theme: %{
                text: :white,
                background: {200, 200, 200},
                active: {200, 200, 200},
                border: :green
              },
              id: Tuple.append(label, :up),
              translate: {x, y},
              height: button_height,
              width: button_width,
              hidden: false
            )
            |> button("",
              theme: %{
                text: :white,
                background: {50, 240, 50},
                active: {50, 240, 50},
                border: :green
              },
              hidden: true,
              id: Tuple.append(label, :down),
              translate: {x, y},
              height: button_height,
              width: button_width
            )
          end
        )
      end,
      t: {16, 140}
    )
  end

  def info(_data) do
  end

  def verify(_any) do
  end
end

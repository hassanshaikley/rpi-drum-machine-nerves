# defmodule DrumMachineNerves.Components.StepIndicator do
#   @moduledoc """
#   Step indicator component that displays which steps are active
#   """
#   use Scenic.Component

#   # use Scenic.Scene, has_children: false
#   import Scenic.Primitives

#   @graph Scenic.Graph.build()
#          |> group(
#            fn graph ->
#              Enum.map(0..(8 - 1), fn col ->
#                {(60 + 4) * col, 4, col}
#              end)
#              |> Enum.reduce(
#                graph,
#                fn obj, graph ->
#                  x = elem(obj, 0)
#                  y = elem(obj, 1)
#                  index = elem(obj, 2)

#                  graph
#                  |> rect({60, 10},
#                    fill: :red,
#                    translate: {x, y},
#                    id: {index, :h}
#                  )
#                end
#              )
#            end,
#            t: {16, 120}
#          )

#   # def add_to_graph(
#   #       graph,
#   #       _data \\ nil,
#   #       [button_width: button_width, button_padding: button_padding, num_cols: num_cols] = _opts
#   #     ) do
#   #   graph
#   #   |> group(
#   #     fn graph ->
#   #       Enum.map(0..(num_cols - 1), fn col ->
#   #         {(button_width + button_padding) * col, button_padding, col}
#   #       end)
#   #       |> Enum.reduce(
#   #         graph,
#   #         fn obj, graph ->
#   #           x = elem(obj, 0)
#   #           y = elem(obj, 1)
#   #           index = elem(obj, 2)

#   #           graph
#   #           |> rect({button_width, 10},
#   #             fill: :red,
#   #             translate: {x, y},
#   #             id: {index, :h}
#   #           )
#   #         end
#   #       )
#   #     end,
#   #     t: {16, 120}
#   #   )
#   # end

#   def init(text, opts) do
#     # modify the already built graph
#     graph =
#       @graph
#       |> Graph.modify(:_root_, &update_opts(&1, styles: opts[:styles]))
#       |> Graph.modify(:text, &text(&1, text))

#     state = %{
#       graph: graph,
#       text: text
#     }

#     {:ok, state, push: graph}
#   end

#   def info(_data) do
#   end

#   def verify(_any) do
#   end
# end

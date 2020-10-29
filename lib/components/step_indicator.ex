defmodule DrumMachineNerves.Components.StepIndicator do
  use Scenic.Component
  import Scenic.Primitives

  alias Scenic.Graph

  # @graph Graph.build()
  #        |> text("", text_align: :center, translate: {100, 200}, color: :red, id: :text)
  #        |> Scenic.Components.button("OFF",
  #          theme: %{
  #            text: :white,
  #            background: :blue,
  #            active: :black,
  #            border: :green
  #          },
  #          id: "shutdown",
  #          translate: {400, 50},
  #          height: 50,
  #          width: 50
  #        )

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

  # def info(data),
  #   do: """
  #     #{IO.ANSI.red()}#{__MODULE__} data must be a bitstring
  #     #{IO.ANSI.yellow()}Received: #{inspect(data)}
  #     #{IO.ANSI.default_color()}
  #   """

  def verify(text) when is_bitstring(text), do: {:ok, text}
  def verify(_), do: {:ok, :a}

  def init(text, opts) do
    # modify the already built graph
    graph = @graph
    #   |> Graph.modify(:_root_, &update_opts(&1, styles: opts[:styles]))
    #   |> Graph.modify(:text, &text(&1, text))

    state = %{
      graph: graph,
      text: "hi"
    }

    {:ok, state, push: graph}
  end

  def handle_info(:loop, %{iteration: iteration} = state) do
    IO.puts("Looping")
    {:ok, state, push: graph}
  end
end

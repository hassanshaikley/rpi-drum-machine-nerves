defmodule RpiMusicMachineNerves.Scene.Crosshair do
  use Scenic.Scene

  alias Scenic.ViewPort
  alias Scenic.Graph
  alias Scenic.Primitive
  import Scenic.Primitives
  import Scenic.Components

  @width 10000
  @height 10000

  @main_menu_graph Graph.build(font: :roboto, font_size: 16)
                   |> rect({@width, @height}, color: :blue, id: :background)
                   |> group(
                     fn graph ->
                       Enum.reduce(
                         [
                           {0, 0, "00"},
                           {100, 0, "01"},
                           {200, 0, "02"},
                           {300, 0, "03"},
                           {400, 0, "04"},
                           {500, 0, "05"},
                           {600, 0, "06"},
                           {700, 0, "07"},
                           {800, 0, "08"}
                         ],
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
                             id: label <> "_up",
                             translate: {x, y},
                             height: 90,
                             width: 90
                           )
                           |> button("",
                             theme: %{
                               text: :white,
                               background: {120, 120, 120},
                               active: {120, 120, 120},
                               border: :green
                             },
                             hidden: true,
                             id: label <> "_down",
                             translate: {x, y},
                             height: 90,
                             width: 90
                           )
                         end
                       )
                     end,
                     t: {5, 5}
                   )

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _) do
    # loop()
    {:ok, @main_menu_graph, push: @main_menu_graph}
  end

  # ============================================================================
  # event handlers

  # --------------------------------------------------------
  def filter_event({:click, "00_up"}, context, state) do
    IO.puts("00")

    updated_graph =
      state
      |> Graph.modify("00_up", fn p ->
        Primitive.put_style(p, :hidden, true)
      end)
      |> Graph.modify("00_down", fn p ->
        Primitive.put_style(p, :hidden, false)
      end)

    IO.inspect(updated_graph)

    {:noreply, %{}, push: updated_graph}
  end

  def filter_event({:click, "01"}, context, graph) do
    IO.puts("01")
    {:noreply, graph}
  end

  def filter_event({:click, "02"}, context, graph) do
    IO.puts("02")
    {:noreply, graph}
  end

  def handle_input(_msg, _, graph) do
    {:noreply, graph}
  end
end

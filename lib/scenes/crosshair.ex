defmodule RpiMusicMachineNerves.Scene.Crosshair do
  use Scenic.Scene

  alias Scenic.ViewPort
  alias Scenic.Graph
  alias Scenic.Primitive
  import Scenic.Primitives
  import Scenic.Components

  @width 10000
  @height 10000

  @button_width 50
  @button_height @button_width
  @button_padding 5

  @main_menu_graph Graph.build(font: :roboto, font_size: 16)
                   |> rect({@width, @height},
                     id: :background,
                     fill: {50, 50, 50}
                   )
                   |> group(
                     fn graph ->
                       graph
                       |> rect({100, 5}, color: :red, id: :header_thing, translate: {5, 2})
                     end,
                     t: {0, 0}
                   )
                   # 640 x 300 (use 280 I guess, 10 for padding otp and bot)
                   # each button is 70 with 5 padding each way?
                   |> group(
                     fn graph ->
                       Enum.reduce(
                         [
                           {(@button_width + @button_padding) * 0, @button_padding, "00"},
                           {(@button_width + @button_padding) * 1, @button_padding, "01"},
                           {(@button_width + @button_padding) * 2, @button_padding, "02"},
                           {(@button_width + @button_padding) * 3, @button_padding, "03"},
                           {(@button_width + @button_padding) * 4, @button_padding, "04"},
                           {(@button_width + @button_padding) * 5, @button_padding, "05"},
                           {(@button_width + @button_padding) * 6, @button_padding, "06"},
                           {(@button_width + @button_padding) * 7, @button_padding, "07"},
                           {(@button_width + @button_padding) * 8, @button_padding, "08"}
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
                             height: @button_height,
                             width: @button_width
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
                             height: @button_height,
                             width: @button_width
                           )
                         end
                       )
                     end,
                     t: {200, 180}
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
  def filter_event({:click, <<id::bytes-size(2)>> <> "_up"}, context, state) do
    updated_graph =
      state
      |> Graph.modify(id <> "_up", fn p ->
        Primitive.put_style(p, :hidden, true)
      end)
      |> Graph.modify(id <> "_down", fn p ->
        Primitive.put_style(p, :hidden, false)
      end)

    ViewPort.release_input(context, [:cursor_button, :cursor_pos])

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, <<id::bytes-size(2)>> <> "_down"}, context, state) do
    IO.inspect(id)
    IO.puts("HIT DOWN")

    updated_graph =
      state
      |> Graph.modify(id <> "_up", fn p ->
        Primitive.put_style(p, :hidden, false)
      end)
      |> Graph.modify(id <> "_down", fn p ->
        Primitive.put_style(p, :hidden, true)
      end)

    ViewPort.release_input(context, [:cursor_button, :cursor_pos])

    {:noreply, updated_graph, push: updated_graph}
  end

  def handle_input(_msg, _, graph) do
    {:noreply, graph}
  end
end

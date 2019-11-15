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
  @buttons Enum.map(0..8, fn x ->
             {(@button_width + @button_padding) * x, @button_padding, Integer.to_string(x) <> "0"}
           end) ++
             Enum.map(0..8, fn x ->
               {(@button_width + @button_padding) * x,
                @button_height + @button_padding + @button_padding, Integer.to_string(x) <> "1"}
             end) ++
             Enum.map(0..8, fn x ->
               {(@button_width + @button_padding) * x, @button_height * 2 + @button_padding * 3,
                Integer.to_string(x) <> "2"}
             end) ++
             Enum.map(0..8, fn x ->
               {(@button_width + @button_padding) * x, @button_height * 3 + @button_padding * 4,
                Integer.to_string(x) <> "3"}
             end)

  @main_menu_graph Graph.build(font: :roboto, font_size: 16)
                   |> rect({@width, @height},
                     id: :background,
                     fill: {50, 50, 50}
                   )
                   |> group(
                     fn graph ->
                       Enum.map(0..8, fn x ->
                         {(@button_width + @button_padding) * x, @button_padding,
                          Integer.to_string(x)}
                       end)
                       |> Enum.reduce(
                         graph,
                         fn obj, graph ->
                           x = elem(obj, 0)
                           y = elem(obj, 1)

                           graph
                           |> rect({@button_width, 10},
                             fill: :red,
                             translate: {x, y},
                             id: "h_#{Integer.to_string(x)}"
                           )
                         end
                       )
                     end,
                     t: {200, 160}
                   )
                   # 640 x 300 (use 280 I guess, 10 for padding otp and bot)
                   # each button is 70 with 5 padding each way?
                   |> group(
                     fn graph ->
                       Enum.reduce(
                         @buttons,
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
    loop()

    graph = Map.put(@main_menu_graph, :iteration, 0)

    {:ok, graph, push: graph}
  end

  def handle_info(:loop, state) do
    iteration = Map.get(state, :iteration)
    IO.inspect(iteration, label: :iteration)

    loop()

    {:noreply, Map.put(state, :iteration, iteration + 1)}
  end

  defp loop do
    Process.send_after(self(), :loop, 200)
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

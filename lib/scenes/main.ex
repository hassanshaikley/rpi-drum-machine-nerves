defmodule RpiDrumMachineNerves.Scene.Main do
  use Scenic.Scene

  alias Scenic.ViewPort
  alias Scenic.Graph
  alias Scenic.Primitive
  import Scenic.Primitives
  import Scenic.Components

  @bpm 120

  @width 800
  @height 480

  @num_rows 6

  @num_cols 4
  @cols @num_cols - 1

  @button_width 46
  @button_height @button_width

  @button_padding 2
  @buttons [
             Enum.map(0..@cols, fn x ->
               {(@button_width + @button_padding) * x, @button_padding,
                Integer.to_string(x) <> "0"}
             end)
             | [
                 Enum.map(0..@cols, fn x ->
                   {(@button_width + @button_padding) * x,
                    @button_height + @button_padding + @button_padding,
                    Integer.to_string(x) <> "1"}
                 end)
                 | [
                     Enum.map(0..@cols, fn x ->
                       {(@button_width + @button_padding) * x,
                        @button_height * 2 + @button_padding * 3, Integer.to_string(x) <> "2"}
                     end)
                     | [
                         Enum.map(0..@cols, fn x ->
                           {(@button_width + @button_padding) * x,
                            @button_height * 3 + @button_padding * 4, Integer.to_string(x) <> "3"}
                         end)
                         | [
                             Enum.map(0..@cols, fn x ->
                               {(@button_width + @button_padding) * x,
                                @button_height * 4 + @button_padding * 5,
                                Integer.to_string(x) <> "4"}
                             end)
                             | [
                                 Enum.map(0..@cols, fn x ->
                                   {(@button_width + @button_padding) * x,
                                    @button_height * 5 + @button_padding * 6,
                                    Integer.to_string(x) <> "5"}
                                 end)
                               ]
                           ]
                       ]
                   ]
               ]
           ]
           |> List.flatten()

  @main_menu_graph Graph.build(font: :roboto, font_size: 16)
                   |> rect({@width, @height},
                     id: :background,
                     fill: {50, 50, 50}
                   )

                   # Header rectangle
                   |> group(
                     fn graph ->
                       graph
                       |> rect({780, 75},
                         fill: :dark_gray,
                         translate: {0, 0},
                         id: "header_rect"
                       )
                       |> text("Nerves Drum Machine",
                         id: :pos,
                         translate: {630, 60},
                         font_size: 16,
                         fill: :black
                       )
                     end,
                     t: {10, 10}
                   )
                   |> button("OFF",
                     theme: %{
                       text: :white,
                       background: :black,
                       active: :black,
                       border: :green
                     },
                     id: "shutdown",
                     translate: {700, 100},
                     height: 50,
                     width: 50
                   )
                   |> text("volume", translate: {450, 112})
                   |> slider({{40, 100}, 50},
                     id: :volume_slider,
                     translate: {500, 100},
                     width: 100
                   )
                   |> group(
                     fn graph ->
                       Enum.map(0..@cols, fn x ->
                         {(@button_width + @button_padding) * x, @button_padding,
                          Integer.to_string(x)}
                       end)
                       |> Enum.reduce(
                         graph,
                         fn obj, graph ->
                           x = elem(obj, 0)
                           y = elem(obj, 1)
                           index = elem(obj, 2)

                           graph
                           |> rect({@button_width, 10},
                             fill: :red,
                             translate: {x, y},
                             id: "h_#{index}"
                           )
                         end
                       )
                     end,
                     t: {16, 160}
                   )
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
                             width: @button_width,
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
                             id: label <> "_down",
                             translate: {x, y},
                             height: @button_height,
                             width: @button_width
                           )
                         end
                       )
                     end,
                     t: {16, 180}
                   )

  # setup

  @active_buttons_initial %{
    "0" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "1" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "2" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "3" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "4" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "5" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "6" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "7" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "8" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "9" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "10" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "11" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "12" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "13" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "14" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
    "15" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false}
  }

  # --------------------------------------------------------
  def init(_, _) do
    graph = Map.put(@main_menu_graph, :iteration, 0)
    graph = Map.put(graph, :active_buttons_cache, @active_buttons_initial)

    Process.send_after(self(), :loop, 2000, [])

    {:ok, graph, push: graph}
  end

  def handle_info(:loop, state) do
    Process.send_after(self(), :loop, bpm_in_ms)

    iteration = state.iteration
    active_buttons_cache = state.active_buttons_cache

    current_index = rem(iteration, @num_cols)

    updated_graph = update_header(state, iteration)

    start_time = Time.utc_now()

    Enum.each(1..@num_rows, fn row ->
      row = row - 1

      row_visible = active_buttons_cache[Integer.to_string(current_index)][Integer.to_string(row)]

      if row_visible do
        case row do
          0 -> AudioPlayer.play_sound("hihat_great.wav")
          1 -> AudioPlayer.play_sound("22inchridecymbal.wav")
          2 -> AudioPlayer.play_sound("triangle.wav")
          3 -> AudioPlayer.play_sound("runnerskick.wav")
          4 -> AudioPlayer.play_sound("hitoms.wav")
          5 -> AudioPlayer.play_sound("snare.wav")
        end
      end
    end)

    end_time = Time.utc_now()

    Time.diff(start_time, end_time, :microsecond) |> IO.inspect()
    {:noreply, updated_graph, push: updated_graph}
  end

  # ============================================================================
  # event handlers

  # --------------------------------------------------------

  def filter_event({:click, <<id::bytes-size(3)>> <> "_up"}, context, state) do
    updated_graph = toggle_button(id, :on, state)

    active_buttons_cache = state.active_buttons_cache

    <<col::binary-size(2), row::binary>> = id

    active_buttons_cache =
      Map.update!(active_buttons_cache, col, fn current_value ->
        Map.update!(current_value, row, fn current_inner_value ->
          true
        end)
      end)

    updated_graph = Map.put(updated_graph, :active_buttons_cache, active_buttons_cache)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, <<id::bytes-size(2)>> <> "_up"}, context, state) do
    updated_graph = toggle_button(id, :on, state)

    <<col::binary-size(1), row::binary>> = id
    active_buttons_cache = state.active_buttons_cache

    active_buttons_cache =
      Map.update!(active_buttons_cache, col, fn current_value ->
        Map.update!(current_value, row, fn current_inner_value ->
          true
        end)
      end)

    updated_graph = Map.put(updated_graph, :active_buttons_cache, active_buttons_cache)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, <<id::bytes-size(3)>> <> "_down"}, context, state) do
    updated_graph = toggle_button(id, :off, state)

    active_buttons_cache = state.active_buttons_cache
    <<col::binary-size(2), row::binary>> = id

    active_buttons_cache =
      Map.update!(active_buttons_cache, col, fn current_value ->
        Map.update!(current_value, row, fn current_inner_value ->
          false
        end)
      end)

    updated_graph = Map.put(updated_graph, :active_buttons_cache, active_buttons_cache)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, <<id::bytes-size(2)>> <> "_down"}, context, state) do
    updated_graph = toggle_button(id, :off, state)

    <<col::binary-size(1), row::binary>> = id
    active_buttons_cache = state.active_buttons_cache

    active_buttons_cache =
      Map.update!(active_buttons_cache, col, fn current_value ->
        Map.update!(current_value, row, fn current_inner_value ->
          false
        end)
      end)

    updated_graph = Map.put(updated_graph, :active_buttons_cache, active_buttons_cache)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, "shutdown"}, context, state) do
    spawn(fn -> :os.cmd('sudo shutdown -h now') end)
    {:noreply, state}
  end

  def handle_input(_msg, _, graph) do
    {:noreply, graph}
  end

  def filter_event({:value_changed, id, value}, context, state) do
    AudioPlayer.set_volume(value)
    {:noreply, state}
  end

  ####### '.###
  # Private.` #
  ########### `

  defp toggle_button(id, :off, state) do
    state
    |> Graph.modify(id <> "_down", fn p ->
      Primitive.put_style(p, :hidden, true)
    end)
    |> Graph.modify(id <> "_up", fn p ->
      Primitive.put_style(p, :hidden, false)
    end)
  end

  defp toggle_button(id, :on, state) do
    state
    |> Graph.modify(id <> "_down", fn p ->
      Primitive.put_style(p, :hidden, false)
    end)
    |> Graph.modify(id <> "_up", fn p ->
      Primitive.put_style(p, :hidden, true)
    end)
  end

  defp update_header(graph, iteration) do
    previous_index = rem(iteration - 1, @num_cols)

    current_index = rem(iteration, @num_cols)

    current_header_id = "h_" <> Integer.to_string(current_index)
    previous_header_id = "h_" <> Integer.to_string(previous_index)

    graph
    |> Graph.modify(current_header_id, fn p ->
      Primitive.put_style(p, :fill, :blue)
    end)
    |> Graph.modify(previous_header_id, fn p ->
      Primitive.put_style(p, :fill, :red)
    end)
    |> Map.put(:iteration, iteration + 1)
  end

  defp bpm_in_ms, do: trunc(60_000 / @bpm)
end

defmodule RpiDrumMachineNerves.Scene.Main do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Primitive
  import Scenic.Primitives

  alias RpiDrumMachineNerves.Component.{
    Header,
    OffButton,
    PushButtons,
    StepIndicator,
    VolumeSlider
  }

  @bpm 120

  @width 800
  @height 480

  @num_rows 6
  @num_cols 16

  @button_width 46
  @button_height @button_width
  @button_padding 2

  # Tuples for every button containing {the left most x value, the top most y value, and the unique button identifier}
  @buttons Enum.map(0..(@num_cols - 1), fn x ->
             Enum.map(0..(@num_rows - 1), fn y ->
               {(@button_width + @button_padding) * x, (@button_height + @button_padding) * y,
                Integer.to_string(x) <> to_string(y)}
             end)
           end)
           |> List.flatten()

  @main_menu_graph Graph.build(font: :roboto, font_size: 16)
                   # Background
                   |> rect({@width, @height},
                     id: :background,
                     fill: {50, 50, 50}
                   )
                   |> Header.add_to_graph()
                   |> OffButton.add_to_graph()
                   |> VolumeSlider.add_to_graph()
                   |> StepIndicator.add_to_graph(nil,
                     button_width: @button_width,
                     button_padding: @button_padding,
                     num_cols: @num_cols
                   )
                   |> PushButtons.add_to_graph(
                     button_width: @button_width,
                     button_height: @button_height,
                     buttons: @buttons
                   )

  # Creates a map of 16 elements thats mapping to each step of music
  # Each has a map of 5 children, which represent the sound being played
  # @active_buttons_initial %{
  #   "0" => %{"0" => false, "1" => false, "2" => false, "3" => false, "4" => false, "5" => false},
  #   ...
  # }
  @active_buttons_initial Enum.reduce(0..15, %{}, fn x, acc ->
                            key = to_string(x)

                            inner_map =
                              Enum.reduce(0..5, %{}, fn x, acc ->
                                Map.put(acc, to_string(x), false)
                              end)

                            Map.put(acc, key, inner_map)
                          end)

  def init(_, _) do
    graph =
      @main_menu_graph
      |> Map.put(:iteration, 0)
      |> Map.put(:active_buttons_cache, @active_buttons_initial)

    Process.send_after(self(), :loop, 100, [])

    {:ok, graph, push: graph}
  end

  def handle_info(:loop, state) do
    Process.send_after(self(), :loop, bpm_in_ms())

    current_index = rem(state.iteration, @num_cols)

    updated_graph = update_header(state)

    start_time = Time.utc_now()

    Enum.each(1..@num_rows, fn row ->
      row = row - 1

      row_visible =
        state.active_buttons_cache[Integer.to_string(current_index)][Integer.to_string(row)]

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

  def filter_event({:click, <<id::bytes-size(3)>> <> "_up"}, _context, state) do
    button_down = true
    updated_graph = toggle_button(id, button_down, state)

    <<col::binary-size(2), row::binary>> = id

    active_buttons_cache = update_button(state, col, row, button_down)

    updated_graph = Map.put(updated_graph, :active_buttons_cache, active_buttons_cache)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, <<id::bytes-size(2)>> <> "_up"}, _context, state) do
    button_down = true

    updated_graph = toggle_button(id, button_down, state)

    <<col::binary-size(1), row::binary>> = id

    active_buttons_cache = update_button(state, col, row, button_down)

    updated_graph = Map.put(updated_graph, :active_buttons_cache, active_buttons_cache)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, <<id::bytes-size(3)>> <> "_down"}, _context, state) do
    button_down = false

    updated_graph = toggle_button(id, button_down, state)

    <<col::binary-size(2), row::binary>> = id

    active_buttons_cache = update_button(state, col, row, button_down)

    updated_graph = Map.put(updated_graph, :active_buttons_cache, active_buttons_cache)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, <<id::bytes-size(2)>> <> "_down"}, _context, state) do
    button_down = false
    updated_graph = toggle_button(id, button_down, state)

    <<col::binary-size(1), row::binary>> = id

    active_buttons_cache = update_button(state, col, row, button_down)

    updated_graph = Map.put(updated_graph, :active_buttons_cache, active_buttons_cache)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, "shutdown"}, _context, state) do
    spawn(fn -> :os.cmd('sudo shutdown -h now') end)
    {:noreply, state}
  end

  def filter_event({:value_changed, _id, value}, _context, state) do
    AudioPlayer.set_volume(value)
    {:noreply, state}
  end

  def handle_input(_msg, _, graph) do
    {:noreply, graph}
  end

  ####### '.###
  # Private.` #
  ########### `

  # In scenic to show that a button is down you need two buttons
  # One for how it looks when it is up and another for how it looks when it is down
  # And then hide the inactive button

  defp update_button(%{active_buttons_cache: active_buttons_cache} = _state, col, row, value) do
    Map.update!(active_buttons_cache, col, fn current_value ->
      Map.update!(current_value, row, fn _current_inner_value ->
        value
      end)
    end)
  end

  defp toggle_button(id, button_down, state) do
    state
    |> Graph.modify(id <> "_down", fn p ->
      Primitive.put_style(p, :hidden, !button_down)
    end)
    |> Graph.modify(id <> "_up", fn p ->
      Primitive.put_style(p, :hidden, button_down)
    end)
  end

  defp update_header(%{iteration: iteration} = graph) do
    {current_header_id, previous_header_id} = current_and_previous_header_id(iteration)

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

  defp current_and_previous_header_id(iteration) do
    previous_index = rem(iteration - 1, @num_cols)
    current_index = rem(iteration, @num_cols)
    current_header_id = "h_" <> Integer.to_string(current_index)
    previous_header_id = "h_" <> Integer.to_string(previous_index)
    {current_header_id, previous_header_id}
  end
end

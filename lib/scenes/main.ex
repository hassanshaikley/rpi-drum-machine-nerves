defmodule RpiDrumMachineNerves.Scene.Main do
  @moduledoc """
  Main scene
  """

  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Primitive
  import Scenic.Primitives

  alias RpiDrumMachineNerves.Components.{
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

  # Tuples for every button containing {the left most x value, the top most y value, and the unique button id}
  # This is only used to build the UI
  @buttons Enum.map(0..(@num_cols - 1), fn x ->
             Enum.map(0..(@num_rows - 1), fn y ->
               {(@button_width + @button_padding) * x, (@button_height + @button_padding) * y,
                {x, y}}
             end)
           end)
           |> List.flatten()

  @main_menu_graph Graph.build(font: :roboto, font_size: 16)
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

  def init(_, _) do
    button_store = initialize_button_store

    graph =
      @main_menu_graph
      |> Map.put(:iteration, 0)
      |> Map.put(:button_store, button_store)

    Process.send_after(self(), :loop, 100, [])

    {:ok, graph, push: graph}
  end

  # ============================================================================
  # event handlers
  # --------------------------------------------------------

  def filter_event({:click, {col, row, :up} = id}, _context, state) do
    IO.puts("UP")
    button_down = true
    updated_graph = toggle_button(id, button_down, state)

    update_ets(state.button_store, row, col, button_down)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, {col, row, :down} = id}, _context, state) do
    IO.puts("DOWN")
    button_down = false

    updated_graph = toggle_button(id, button_down, state)

    update_ets(state.button_store, row, col, button_down)

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

  def handle_info(:loop, state) do
    Process.send_after(self(), :loop, bpm_in_ms())

    current_index = rem(state.iteration, @num_cols)

    updated_graph =
      state
      |> update_header()
      |> Map.put(:iteration, state.iteration + 1)

    start_time = Time.utc_now()

    # Iterate through each row in the currently played column and play the sounds that are true
    Enum.each(0..(@num_rows - 1), fn row ->
      [{_key, row_visible}] =
        :ets.lookup(state.button_store, {rem(current_index, @num_cols), row})

      play_sound_for_row(row, row_visible)
    end)

    end_time = Time.utc_now()

    Time.diff(start_time, end_time, :microsecond) |> IO.inspect()
    {:noreply, updated_graph, push: updated_graph}
  end

  def handle_input(_msg, _, graph) do
    {:noreply, graph}
  end

  ####### '.###
  # Private.` #
  ########### `

  defp bpm_in_ms, do: trunc(60_000 / @bpm)

  defp header_id_current(iteration),
    do: {rem(iteration, @num_cols), :h}

  defp header_id_previous(iteration), do: header_id_current(iteration - 1)

  # Keys are :"x_y" (ie 0_5) and values are true if the button is down, false if the button is up
  # The reason they are atoms is because atom comparison is more performant. I did my own benchmarks
  # But here's another (source: https://github.com/devonestes/fast-elixir#comparing-strings-vs-atoms-code)
  defp initialize_button_store do
    button_store = :ets.new(:button_store, [:set, :protected])

    # :ets.insert(button_store, {"#{0}_#{0}", false})

    Enum.each(0..15, fn x ->
      Enum.each(0..5, fn y ->
        :ets.insert(button_store, {{x, y}, false})
      end)
    end)

    button_store
  end

  defp play_sound_for_row(row, false), do: :noop
  defp play_sound_for_row(row, _) when row == 0, do: AudioPlayer.play_sound("hihat_great.wav")
  defp play_sound_for_row(row, _) when row == 1, do: AudioPlayer.play_sound("ride_cymbal.wav")
  defp play_sound_for_row(row, _) when row == 2, do: AudioPlayer.play_sound("triangle.wav")
  defp play_sound_for_row(row, _) when row == 3, do: AudioPlayer.play_sound("runnerskick.wav")
  defp play_sound_for_row(row, _) when row == 4, do: AudioPlayer.play_sound("hitoms.wav")
  defp play_sound_for_row(row, _) when row == 5, do: AudioPlayer.play_sound("snare.wav")

  # In scenic to show that a button is down you need two buttons
  # One for how it looks when it is up and another for how it looks when it is down
  # And then hide the inactive button
  defp toggle_button({col, row, down} = id, button_down, state) do
    IO.puts("TOGGLING")

    state
    |> Graph.modify({col, row, :down}, fn p ->
      Primitive.put_style(p, :hidden, !button_down)
    end)
    |> Graph.modify({col, row, :up}, fn p ->
      Primitive.put_style(p, :hidden, button_down)
    end)
  end

  defp update_header(%{iteration: iteration} = graph) do
    graph
    |> Graph.modify(header_id_current(iteration), fn p ->
      Primitive.put_style(p, :fill, :blue)
    end)
    |> Graph.modify(header_id_previous(iteration), fn p ->
      Primitive.put_style(p, :fill, :red)
    end)
  end

  defp update_ets(button_store, row, col, button_down) do
    :ets.insert(button_store, {{col, row}, button_down})
  end
end

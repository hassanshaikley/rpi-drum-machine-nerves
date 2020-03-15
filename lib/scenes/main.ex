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
  # This is only used to build the UI
  @buttons Enum.map(0..(@num_cols - 1), fn x ->
             Enum.map(0..(@num_rows - 1), fn y ->
               {(@button_width + @button_padding) * x, (@button_height + @button_padding) * y,
                Integer.to_string(x) <> to_string(y)}
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
    # Initialize the ets store
    button_store = initialize_button_store()

    graph =
      @main_menu_graph
      |> Map.put(:iteration, 0)
      |> Map.put(:button_store, button_store)

    # a protected process means only the process that created it can write to it

    Process.send_after(self(), :loop, 100, [])

    {:ok, graph, push: graph}
  end

  def handle_info(:loop, state) do
    Process.send_after(self(), :loop, bpm_in_ms())

    current_index = rem(state.iteration, @num_cols)

    updated_graph = update_header(state)

    start_time = Time.utc_now()

    # Iterate through each row in the currently played column and play the sounds that are true
    Enum.each(1..@num_rows, fn row ->
      row = row - 1

      [{_key, row_visible}] =
        :ets.lookup(state.button_store, "#{rem(current_index, @num_cols)}_#{row}")

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

    update_ets(state.button_store, row, col, button_down)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, <<id::bytes-size(2)>> <> "_up"}, _context, state) do
    button_down = true

    updated_graph = toggle_button(id, button_down, state)

    <<col::binary-size(1), row::binary>> = id

    update_ets(state.button_store, row, col, button_down)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, <<id::bytes-size(3)>> <> "_down"}, _context, state) do
    button_down = false

    updated_graph = toggle_button(id, button_down, state)

    <<col::binary-size(2), row::binary>> = id

    update_ets(state.button_store, row, col, button_down)

    {:noreply, updated_graph, push: updated_graph}
  end

  def filter_event({:click, <<id::bytes-size(2)>> <> "_down"}, _context, state) do
    button_down = false
    updated_graph = toggle_button(id, button_down, state)

    <<col::binary-size(1), row::binary>> = id

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

  def handle_input(_msg, _, graph) do
    {:noreply, graph}
  end

  ####### '.###
  # Private.` #
  ########### `

  # Keys are x_y (ie 0_5) and values are true if the button is down, false if the button is up
  defp initialize_button_store() do
    button_store = :ets.new(:button_store, [:set, :protected])

    Enum.each(0..15, fn x ->
      Enum.each(0..5, fn y ->
        :ets.insert(button_store, {"#{x}_#{y}", false})
      end)
    end)

    button_store
  end

  # In scenic to show that a button is down you need two buttons
  # One for how it looks when it is up and another for how it looks when it is down
  # And then hide the inactive button

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
    graph
    |> Graph.modify(current_header_id(iteration), fn p ->
      Primitive.put_style(p, :fill, :blue)
    end)
    |> Graph.modify(previous_header_id(iteration), fn p ->
      Primitive.put_style(p, :fill, :red)
    end)
    |> Map.put(:iteration, iteration + 1)
  end

  defp bpm_in_ms, do: trunc(60_000 / @bpm)

  defp update_ets(button_store, row, col, button_down) do
    :ets.insert(button_store, {"#{col}_#{row}", button_down})
  end

  defp current_header_id(iteration) when iteration >= 16,
    do: iteration |> rem(@num_cols) |> current_header_id()

  defp current_header_id(iteration) when iteration == -1, do: "15_h"
  defp current_header_id(iteration) when iteration == 0, do: "0_h"
  defp current_header_id(iteration) when iteration == 1, do: "1_h"
  defp current_header_id(iteration) when iteration == 2, do: "2_h"
  defp current_header_id(iteration) when iteration == 3, do: "3_h"
  defp current_header_id(iteration) when iteration == 4, do: "4_h"
  defp current_header_id(iteration) when iteration == 5, do: "5_h"
  defp current_header_id(iteration) when iteration == 6, do: "6_h"
  defp current_header_id(iteration) when iteration == 7, do: "7_h"
  defp current_header_id(iteration) when iteration == 8, do: "8_h"
  defp current_header_id(iteration) when iteration == 9, do: "9_h"
  defp current_header_id(iteration) when iteration == 10, do: "10_h"
  defp current_header_id(iteration) when iteration == 11, do: "11_h"
  defp current_header_id(iteration) when iteration == 12, do: "12_h"
  defp current_header_id(iteration) when iteration == 13, do: "13_h"
  defp current_header_id(iteration) when iteration == 14, do: "14_h"
  defp current_header_id(iteration) when iteration == 15, do: "15_h"

  defp previous_header_id(iteration), do: current_header_id(iteration - 1)
end

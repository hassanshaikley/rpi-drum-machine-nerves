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
  @bpm_in_ms trunc(60_000 / @bpm)

  @width 800
  @height 480

  @num_rows 5
  @num_cols 8

  # @button_width 46 * 1.5
  # @button_height @button_width
  # @button_padding 2 * 1.5

  @button_width 60
  @button_height @button_width
  @button_padding 4

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
    state =
      @main_menu_graph
      |> Map.put(:iteration, 0)

    # Start the loop
    Process.send_after(self(), :loop, 1000, [])

    {:ok, state, push: state}
  end

  # ============================================================================
  # event handlers
  # --------------------------------------------------------

  def filter_event({:click, {col, row, :up} = id}, _context, state) do
    updated_state = toggle_button(id, true, state)
    update_ets(row, col, true)

    {:noreply, updated_state, push: updated_state}
  end

  def filter_event({:click, {col, row, :down} = id}, _context, state) do
    updated_state = toggle_button(id, false, state)
    update_ets(row, col, false)

    {:noreply, updated_state, push: updated_state}
  end

  def filter_event({:click, "shutdown"}, _context, state) do
    spawn(fn -> :os.cmd('sudo shutdown -h now') end)
    {:noreply, state}
  end

  def filter_event({:value_changed, _id, value}, _context, state) do
    AudioPlayer.set_volume(value)
    {:noreply, state}
  end

  # Code that is run each beat
  def handle_info(:loop, state) do
    Process.send(Loop, :loop, [])
    Process.send_after(self(), :loop, @bpm_in_ms)

    updated_state =
      state
      |> update_header()

    {:noreply, updated_state, push: updated_state}
  end

  def handle_input(_msg, _, state) do
    {:noreply, state}
  end

  def get_current_iteration() do
    [counter_current: iteration] = :ets.lookup(:button_store, :counter_current)

    iteration
  end

  def get_previous_iteration() do
    [counter_previous: iteration] = :ets.lookup(:button_store, :counter_previous)

    iteration
  end

  ####### '.###
  # Private.` #
  ########### `

  defp header_id_current(),
    do: {get_current_iteration(), :h}

  defp header_id_previous(), do: {get_previous_iteration(), :h}

  # In scenic to show that a button is down you need two buttons
  # One for how it looks when it is up and another for how it looks when it is down
  # And then hide the inactive button
  defp toggle_button({col, row, _down}, button_down, state) do
    state
    |> Graph.modify({col, row, :down}, fn p ->
      Primitive.put_style(p, :hidden, !button_down)
    end)
    |> Graph.modify({col, row, :up}, fn p ->
      Primitive.put_style(p, :hidden, button_down)
    end)
  end

  defp update_header(state) do
    state
    |> Graph.modify(header_id_current(), fn p ->
      Primitive.put_style(p, :fill, :blue)
    end)
    |> Graph.modify(header_id_previous(), fn p ->
      Primitive.put_style(p, :fill, :red)
    end)
  end

  defp update_ets(row, col, button_down) do
    :ets.insert(:button_store, {{col, row}, button_down})
  end
end

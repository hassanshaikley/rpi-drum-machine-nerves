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
    initialize_button_store()

    state =
      @main_menu_graph
      |> Map.put(:iteration, 0)

    Process.send_after(self(), :loop, 1000, [])

    # Benchee.run(
    #   %{
    #     "rem" => fn -> rem(14, 7) end,
    #     "matching" => fn -> get_next_iteration(5) end
    #   },
    #   time: 5,
    #   print: [fast_warning: false]
    # )

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
    start_time = Time.utc_now()

    Process.send_after(self(), :loop, @bpm_in_ms)

    current_iteration = update_iteration()

    if sound_playing?(current_iteration, 0), do: AudioPlayer.play_sound("hihat.wav")
    if sound_playing?(current_iteration, 1), do: AudioPlayer.play_sound("snare.wav")
    if sound_playing?(current_iteration, 2), do: AudioPlayer.play_sound("triangle.wav")
    if sound_playing?(current_iteration, 3), do: AudioPlayer.play_sound("runnerskick.wav")
    if sound_playing?(current_iteration, 4), do: AudioPlayer.play_sound("hitoms.wav")
    # if sound_playing?(current_iteration, 5), do: AudioPlayer.play_sound("ride_cymbal.wav")

    updated_state =
      state
      |> update_header()

    end_time = Time.utc_now()

    Time.diff(start_time, end_time, :microsecond) |> IO.inspect()
    {:noreply, updated_state, push: updated_state}
  end

  def handle_input(_msg, _, state) do
    {:noreply, state}
  end

  ####### '.###
  # Private.` #
  ########### `

  defp sound_playing?(iteration, row) do
    case :ets.lookup(:button_store, {iteration, row}) do
      [{_, true}] -> true
      _ -> false
    end
  end

  defp get_current_iteration() do
    [counter_current: iteration] = :ets.lookup(:button_store, :counter_current)

    iteration
  end

  defp get_previous_iteration() do
    [counter_previous: iteration] = :ets.lookup(:button_store, :counter_previous)

    iteration
  end

  defp header_id_current(),
    do: {get_current_iteration(), :h}

  defp header_id_previous(), do: {get_previous_iteration(), :h}

  defp initialize_button_store do
    :ets.new(:button_store, [:set, :named_table, read_concurrency: true, write_concurrency: true])

    Enum.each(0..(@num_cols - 1), fn x ->
      Enum.each(0..(@num_rows - 1), fn y ->
        :ets.insert(:button_store, {{x, y}, false})
      end)
    end)
  end

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

  defp update_iteration() do
    :ets.update_counter(
      :button_store,
      :counter_previous,
      {2, 1, @num_cols - 1, 0},
      {:counter_previous, @num_cols - 1}
    )

    :ets.update_counter(
      :button_store,
      :counter_current,
      {2, 1, @num_cols - 1, 0},
      {:counter_current, 0}
    )
  end
end

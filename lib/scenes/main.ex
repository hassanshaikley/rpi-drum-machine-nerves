defmodule DrumMachineNerves.Scene.Main do
  @moduledoc """
  Main scene
  """

  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.Primitive
  import Scenic.Primitives

  alias DrumMachineNerves.Optimizations

  alias DrumMachineNerves.Components.{
    BpmControls,
    Header,
    OffButton,
    PushButtons,
    StepIndicator,
    VolumeControls
  }

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
                   #  |> rect({@width, @height},
                   #    id: :background,
                   #    fill: {50, 50, 50}
                   #  )
                   |> Header.add_to_graph()
                   |> OffButton.add_to_graph()
                   |> VolumeControls.add_to_graph()
                   |> StepIndicator.add_to_graph()
                   |> BpmControls.add_to_graph()
                   #  |> StepIndicator.add_to_graph(nil,
                   #    button_width: @button_width,
                   #    button_padding: @button_padding,
                   #    num_cols: @num_cols
                   #  )
                   |> PushButtons.add_to_graph(
                     button_width: @button_width,
                     button_height: @button_height,
                     buttons: @buttons
                   )

  def init(_, _) do
    state =
      @main_menu_graph
      |> Map.put(:iteration, 0)
      |> Map.put(
        :button_state,
        Enum.reduce(0..(@num_cols - 1), %{}, fn col, acc ->
          acc
          |> Map.put(Optimizations.encode_iteration_row(col, 0), false)
          |> Map.put(Optimizations.encode_iteration_row(col, 1), false)
          |> Map.put(Optimizations.encode_iteration_row(col, 2), false)
          |> Map.put(Optimizations.encode_iteration_row(col, 3), false)
          |> Map.put(Optimizations.encode_iteration_row(col, 4), false)
        end)
      )
      |> Map.put(:bpm_in_ms, bpm_to_ms(90))
      |> Map.put(:bpm, 90)

    # |> add_debug_text("poop")

    # :os.cmd('espeak -ven+f5 -k5 -w /tmp/out.wav Hello')
    # :os.cmd('aplay -q /tmp/out.wav')

    # Start after a second to give the app a chance to initialize
    Process.send_after(self(), :loop, 1000, [])

    {:ok, state, push: state}
  end

  # ============================================================================
  # event handlers
  # --------------------------------------------------------

  def filter_event({:click, {col, row, :up} = id}, _context, state) do
    new_state =
      toggle_button(id, true, state)
      |> update_button_state(row, col, true)

    {:noreply, new_state, push: new_state}
  end

  def filter_event({:click, {col, row, :down} = id}, _context, state) do
    new_state =
      toggle_button(id, false, state)
      |> update_button_state(row, col, false)

    {:noreply, new_state, push: new_state}
  end

  def filter_event({:click, "shutdown"}, _context, state) do
    # spawn(fn -> :os.cmd('poweroff') end)
    # spawn(fn -> Nerves.Runtime.poweroff() end)
    spawn(fn -> System.cmd("poweroff", ["now"]) end)

    {:noreply, state}
  end

  def filter_event({:value_changed, _id, value}, _context, state) do
    AudioPlayer.set_volume(value)
    {:noreply, state}
  end

  def filter_event({:click, :volume_up}, _context, state) do
    AudioPlayer.increase_volume()
    {:noreply, state}
  end

  def filter_event({:click, :volume_down}, _context, state) do
    AudioPlayer.decrease_volume()
    {:noreply, state}
  end

  def filter_event({:click, :increase_bpm}, _context, state) do
    new_bpm = state.bpm + 1
    new_bpm_in_ms = bpm_to_ms(new_bpm)

    new_state =
      state
      |> Map.put(:bpm, new_bpm)
      |> Map.put(:bpm_in_ms, new_bpm_in_ms)
      |> Graph.modify(:bpm_label, &text(&1, "bpm (" <> Integer.to_string(new_bpm) <> ")"))

    # new_bpm_in_ms = state.bpm_in_ms + 6 * 5
    # new_state = Map.put(state, :bpm_in_ms, new_bpm_in_ms)
    # new_bpm =
    # ms_to_bpm(new_bpm_in_ms) |> IO.inspect(label: :new_bpm_in_ms)
    # Grape.modify(graph, :debug, &text(&1, txt))

    {:noreply, new_state, push: new_state}
  end

  def filter_event({:click, :decrease_bpm}, _context, state) do
    new_bpm = state.bpm - 1
    new_bpm_in_ms = bpm_to_ms(new_bpm)

    new_state =
      state
      |> Map.put(:bpm, new_bpm)
      |> Map.put(:bpm_in_ms, new_bpm_in_ms)
      |> Graph.modify(:bpm_label, &text(&1, "bpm (" <> Integer.to_string(new_bpm) <> ")"))

    # <> Integer.to_string(new_bpm) <>

    {:noreply, new_state, push: new_state}
  end

  # Code that is run each beat
  def handle_info(:loop, %{iteration: iteration, bpm_in_ms: bpm_in_ms} = state) do
    Process.send_after(self(), :loop, bpm_in_ms)

    # start_time = Time.utc_now()

    current_iteration = iteration
    next_iteration = Optimizations.get_next_iteration(current_iteration)

    spawn(fn ->
      if sound_playing?(current_iteration, 0, state), do: AudioPlayer.play_sound("hihat.wav")
      if sound_playing?(current_iteration, 1, state), do: AudioPlayer.play_sound("snare.wav")
      if sound_playing?(current_iteration, 2, state), do: AudioPlayer.play_sound("triangle.wav")

      if sound_playing?(current_iteration, 3, state),
        do: AudioPlayer.play_sound("runnerskick.wav")

      if sound_playing?(current_iteration, 4, state), do: AudioPlayer.play_sound("hitoms.wav")
    end)

    # Process.send(StepIndicator, :loop, [])

    new_state =
      state
      |> update_step_indicator
      |> Map.put(:iteration, next_iteration)

    # Time.diff(start_time, Time.utc_now(), :microsecond)
    # |> IO.inspect()

    {:noreply, new_state, push: new_state}
  end

  def handle_input(_msg, _, state) do
    {:halt, state}
  end

  ####### '.###
  # Private.` #
  ########### `

  defp bpm_to_ms(bpm), do: trunc(60_000 / bpm)

  defp sound_playing?(iteration, row, %{button_state: button_state}) do
    Map.get(button_state, Optimizations.encode_iteration_row(iteration, row))
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

  defp update_step_indicator(%{iteration: iteration} = state) do
    state
    |> Graph.modify({iteration, :h}, fn p ->
      Primitive.put_style(p, :fill, :blue)
    end)
    |> Graph.modify({Optimizations.get_previous_iteration(iteration), :h}, fn p ->
      Primitive.put_style(p, :fill, :red)
    end)
  end

  defp update_button_state(%{button_state: button_state} = state, row, col, button_down) do
    new_button_state =
      Map.put(button_state, Optimizations.encode_iteration_row(col, row), button_down)

    Map.put(state, :button_state, new_button_state)
  end

  defp add_debug_text(graph, txt), do: Grape.modify(graph, :debug, &text(&1, txt))
end

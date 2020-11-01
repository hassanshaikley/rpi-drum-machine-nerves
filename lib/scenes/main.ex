defmodule DrumMachineNerves.Scene.Main do
  @moduledoc """
  Main scene
  """

  use Scenic.Scene

  alias Scenic.Graph
  import Scenic.Primitives

  alias DrumMachineNerves.Optimizations

  alias DrumMachineNerves.Components.{
    BpmControls,
    # Header,
    PushButtons,
    StepIndicator,
    VolumeControls
  }

  @num_rows 5
  @num_cols 8

  @main_menu_graph Graph.build(font: :roboto, font_size: 16)
                   #  |> Header.add_to_graph()
                   |> VolumeControls.add_to_graph()
                   |> StepIndicator.add_to_graph()
                   |> BpmControls.add_to_graph()
                   #  |> StepIndicator.add_to_graph(nil,
                   #    button_width: @button_width,
                   #    button_padding: @button_padding,
                   #    num_cols: @num_cols
                   #  )
                   |> PushButtons.add_to_graph()

  def init(_, _) do
    Optimizations.disable_hdmi()
    Optimizations.disable_ethernet()
    Optimizations.disable_usb()

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
      |> Map.put(:volume, 50)

    # |> add_debug_text("poop")

    # Start after a second to give the app a chance to initialize

    # Used to be 1000 insteaad of 1
    Process.send_after(self(), :loop, 1, [])

    {:ok, state, push: state}
  end

  # ============================================================================
  # event handlers
  # --------------------------------------------------------

  def filter_event({:click, {col, row, :up} = id}, _context, state) do
    new_state =
      state
      |> update_button_state(row, col, true)

    {:noreply, new_state, push: new_state}
  end

  def filter_event({:click, {col, row, :down} = id}, _context, state) do
    new_state =
      state
      |> update_button_state(row, col, false)

    {:noreply, new_state, push: new_state}
  end

  def filter_event({:click, :poweroff}, _context, state) do
    # spawn(fn -> :os.cmd('poweroff') end)
    # spawn(fn -> Nerves.Runtime.poweroff() end)

    # Tried the thing below it didnt wowrk
    # spawn(fn -> System.cmd("poweroff", ["now"]) end)

    {:noreply, state}
  end

  def filter_event({:click, :volume_up}, _context, state) do
    new_volume = increase_volume(state)

    state =
      Graph.modify(
        state,
        :volume_label,
        &text(&1, "volume (" <> Integer.to_string(new_volume) <> ")")
      )
      |> Map.put(:volume, new_volume)

    {:noreply, state, push: state}
  end

  def filter_event({:click, :volume_down}, _context, state) do
    new_volume = decrease_volume(state)

    state =
      Graph.modify(
        state,
        :volume_label,
        &text(&1, "volume (" <> Integer.to_string(new_volume) <> ")")
      )
      |> Map.put(:volume, new_volume)

    {:noreply, state, push: state}
  end

  def filter_event({:click, :increase_bpm}, _context, state) do
    new_bpm = state.bpm + 1
    GenServer.cast(DrumMachineNerves.Components.BpmControls, {:update_bpm, new_bpm})

    new_bpm_in_ms = bpm_to_ms(new_bpm)

    new_state =
      state
      |> Map.put(:bpm, new_bpm)
      |> Map.put(:bpm_in_ms, new_bpm_in_ms)

    {:noreply, new_state}
  end

  def filter_event({:click, :decrease_bpm}, _context, state) do
    new_bpm = state.bpm - 1
    GenServer.cast(DrumMachineNerves.Components.BpmControls, {:update_bpm, new_bpm})

    new_bpm_in_ms = bpm_to_ms(new_bpm)

    new_state =
      state
      |> Map.put(:bpm, new_bpm)
      |> Map.put(:bpm_in_ms, new_bpm_in_ms)

    {:noreply, new_state}
  end

  def handle_info(:loop, %{iteration: iteration, bpm_in_ms: bpm_in_ms} = state) do
    Process.send_after(self(), :loop, bpm_in_ms)

    # start_time = Time.utc_now()
    IO.inspect(state.bpm)

    next_iteration = Optimizations.get_next_iteration(iteration)

    GenServer.cast(DrumMachineNerves.Components.StepIndicator, {:loop, iteration})

    play_active_audio(iteration, state)

    new_state = Map.put(state, :iteration, next_iteration)

    # Time.diff(Time.utc_now(), start_time, :microsecond) |> IO.inspect()
    {:noreply, new_state}
  end

  def handle_input(_msg, _, state) do
    {:halt, state}
  end

  ####### '.###
  # Private.` #
  ########### `

  defp increase_volume(%{volume: volume}) do
    volume
    |> increment_volume
    |> AudioPlayer.set_volume()
  end

  defp decrease_volume(%{volume: volume}) do
    volume
    |> decrement_volume()
    |> AudioPlayer.set_volume()
  end

  def increment_volume(volume) when volume <= 90, do: volume + 10
  def increment_volume(_), do: 100

  def decrement_volume(volume) when volume >= 10, do: volume - 10
  def decrement_volume(_), do: 0

  defp play_active_audio(current_iteration, state) do
    spawn(fn ->
      if sound_playing?(current_iteration, 0, state), do: AudioPlayer.play_sound("hihat.wav")
      if sound_playing?(current_iteration, 1, state), do: AudioPlayer.play_sound("snare.wav")
      if sound_playing?(current_iteration, 2, state), do: AudioPlayer.play_sound("triangle.wav")
      if sound_playing?(current_iteration, 3, state), do: AudioPlayer.play_sound("kick.wav")
      if sound_playing?(current_iteration, 4, state), do: AudioPlayer.play_sound("hitoms.wav")
    end)
  end

  defp bpm_to_ms(bpm), do: trunc(60_000 / bpm)

  defp sound_playing?(iteration, row, %{button_state: button_state}) do
    Map.get(button_state, Optimizations.encode_iteration_row(iteration, row))
  end

  defp update_button_state(%{button_state: button_state} = state, row, col, button_down) do
    new_button_state =
      Map.put(button_state, Optimizations.encode_iteration_row(col, row), button_down)

    Map.put(state, :button_state, new_button_state)
  end

  defp add_debug_text(graph, txt), do: Graph.modify(graph, :debug, &text(&1, txt))
end

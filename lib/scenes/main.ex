defmodule RpiDrumMachineNerves.Scene.Main do
  @moduledoc """
  Main scene
  """

  use Scenic.Scene

  import Scenic.Primitives

  alias Scenic.Graph
  alias RpiDrumMachineNerves.{AudioPlayer, Optimizations}

  alias RpiDrumMachineNerves.Components.{
    BpmControls,
    Header,
    InstrumentLabels,
    PushButtons,
    StepIndicator,
    VolumeControls
  }

  @num_cols 8

  @main_menu_graph Graph.build(font: :roboto_mono, font_size: 16)
                   |> rectangle({800, 480}, fill: {56, 55, 61})
                   |> Header.add_to_graph()
                   |> VolumeControls.add_to_graph()
                   |> StepIndicator.add_to_graph()
                   |> BpmControls.add_to_graph()
                   |> PushButtons.add_to_graph()
                   |> InstrumentLabels.add_to_graph()

  def init(_, _) do
    # Optimizations.disable_hdmi()
    # Optimizations.disable_ethernet()
    # Optimizations.disable_usb()

    graph = @main_menu_graph

    state =
      %{
        graph: graph,
        bpm: 200,
        bpm_in_ms: bpm_to_ms(200),
        volume: 70,
        iteration: 0
      }
      |> init_button_state()

    Process.send_after(self(), :loop, 5000, [])

    {:ok, state, push: state.graph}
  end

  # ============================================================================
  # event handlers
  # --------------------------------------------------------

  def filter_event({:click, {col, row, :up}}, _context, state) do
    new_state = update_button_state(state, row, col, true)

    {:noreply, new_state}
  end

  def filter_event({:click, {col, row, :down}}, _context, state) do
    new_state = update_button_state(state, row, col, false)

    {:noreply, new_state}
  end

  def filter_event({:click, :volume_up}, _context, state) do
    new_volume = increase_volume(state)
    GenServer.cast(RpiDrumMachineNerves.Components.VolumeControls, {:update_volume, new_volume})
    new_state = Map.put(state, :volume, new_volume)
    {:noreply, new_state}
  end

  def filter_event({:click, :volume_down}, _context, state) do
    new_volume = decrease_volume(state)
    GenServer.cast(RpiDrumMachineNerves.Components.VolumeControls, {:update_volume, new_volume})
    new_state = Map.put(state, :volume, new_volume)
    {:noreply, new_state}
  end

  def filter_event({:click, :increase_bpm}, _context, state) do
    new_bpm = state.bpm + 1

    GenServer.cast(RpiDrumMachineNerves.Components.BpmControls, {:update_bpm, new_bpm})

    new_bpm_in_ms = bpm_to_ms(new_bpm)

    new_state =
      state
      |> Map.put(:bpm, new_bpm)
      |> Map.put(:bpm_in_ms, new_bpm_in_ms)

    {:noreply, new_state}
  end

  def filter_event({:click, :decrease_bpm}, _context, state) do
    new_bpm = state.bpm - 1
    GenServer.cast(RpiDrumMachineNerves.Components.BpmControls, {:update_bpm, new_bpm})

    new_bpm_in_ms = bpm_to_ms(new_bpm)

    new_state =
      state
      |> Map.put(:bpm, new_bpm)
      |> Map.put(:bpm_in_ms, new_bpm_in_ms)

    {:noreply, new_state}
  end

  def handle_info(:loop, %{iteration: iteration, bpm_in_ms: bpm_in_ms} = state) do
    # Process.send_after(self(), :loop, bpm_in_ms)
    MicroTimer.send_after(bpm_in_ms * 1000, :loop)
    GenServer.cast(StepIndicator, {:loop, iteration})
    play_active_audio(iteration, state)

    new_state = Map.put(state, :iteration, get_next_iteration(iteration))

    :erlang.yield()
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

  defp init_button_state(state) do
    Map.put(
      state,
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
    if audio_playing?(current_iteration, 0, state), do: AudioPlayer.play_audio([42, 0, 127, 9])
    if audio_playing?(current_iteration, 1, state), do: AudioPlayer.play_audio([38, 0, 127, 9])
    if audio_playing?(current_iteration, 2, state), do: AudioPlayer.play_audio([49, 0, 127, 9])
    if audio_playing?(current_iteration, 3, state), do: AudioPlayer.play_audio([35, 0, 127, 9])
    if audio_playing?(current_iteration, 4, state), do: AudioPlayer.play_audio([47, 0, 127, 9])

    # AudioPlayer.play_audio([42, 0, 127, 9])
  end

  defp bpm_to_ms(bpm), do: trunc(60_000 / bpm)

  defp audio_playing?(iteration, row, %{button_state: button_state}) do
    Map.get(button_state, Optimizations.encode_iteration_row(iteration, row))
  end

  defp update_button_state(%{button_state: button_state} = state, row, col, button_down) do
    new_button_state =
      Map.put(button_state, Optimizations.encode_iteration_row(col, row), button_down)

    Map.put(state, :button_state, new_button_state)
  end

  defp get_next_iteration(i), do: rem(i + 1, 8)
end

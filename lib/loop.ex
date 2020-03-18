defmodule RpiDrumMachineNerves.Loop do
  @moduledoc """
  Computation that happens each loop
  """
  use GenServer

  @bpm 120
  @bpm_in_ms trunc(60_000 / @bpm)

  def start_link(opts) do
    IO.puts("Loop.start_link")

    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(state) do
    send(self(), :loop)

    {:ok, state}
  end

  def handle_info(:loop, state) do
    # Process.send_after(self(), :loop, @bpm_in_ms, [])
    IO.puts("IN DA LOOPER")

    # Code that is run each beat
    # start_time = Time.utc_now()

    # # Process.send_after(self(), :loop, @bpm_in_ms)

    current_iteration = update_iteration()

    if sound_playing?(current_iteration, 0), do: AudioPlayer.play_sound("hihat.wav")
    if sound_playing?(current_iteration, 1), do: AudioPlayer.play_sound("snare.wav")
    if sound_playing?(current_iteration, 2), do: AudioPlayer.play_sound("triangle.wav")
    if sound_playing?(current_iteration, 3), do: AudioPlayer.play_sound("runnerskick.wav")
    if sound_playing?(current_iteration, 4), do: AudioPlayer.play_sound("hitoms.wav")
    # # if sound_playing?(current_iteration, 5), do: AudioPlayer.play_sound("ride_cymbal.wav")

    # updated_state =
    #   state
    #   |> update_header()

    # end_time = Time.utc_now()

    # Time.diff(start_time, end_time, :microsecond) |> IO.inspect()
    # {:noreply, updated_state, push: updated_state}

    {:noreply, state}
  end

  defp sound_playing?(iteration, row) do
    case :ets.lookup(:button_store, {iteration, row}) do
      [{_, true}] -> true
      _ -> false
    end
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

defmodule RpiDrumMachineNerves.Loop do
  @moduledoc """
  Computation that happens each loop
  """
  use GenServer

  @bpm 120
  @bpm_in_ms trunc(60_000 / @bpm)

  @num_cols 8
  @num_rows 5

  def start_link(opts) do
    IO.puts("Loop.start_link")

    initialize_button_store()

    GenServer.start_link(__MODULE__, :ok, name: Loop)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def handle_info(:loop, state) do
    IO.puts("L1")
    current_iteration = get_current_iteration
    IO.puts("L2")

    if sound_playing?(current_iteration, 0), do: AudioPlayer.play_sound("hihat.wav")
    if sound_playing?(current_iteration, 1), do: AudioPlayer.play_sound("snare.wav")
    if sound_playing?(current_iteration, 2), do: AudioPlayer.play_sound("triangle.wav")
    if sound_playing?(current_iteration, 3), do: AudioPlayer.play_sound("runnerskick.wav")
    if sound_playing?(current_iteration, 4), do: AudioPlayer.play_sound("hitoms.wav")
    IO.puts("L3")

    Process.send_after(self(), :update_iteration, 20, [])
    IO.puts("L4")

    {:noreply, state}
  end

  def handle_info(:update_iteration, state) do
    IO.puts("Updating iteration")
    update_iteration()
    IO.puts("Done Updating iteration")

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

  defp sound_playing?(iteration, row) do
    case :ets.lookup(:button_store, {iteration, row}) do
      [{_, true}] -> true
      _ -> false
    end
  end

  defp initialize_button_store do
    :ets.new(:button_store, [
      :named_table,
      :public,
      :set,
      read_concurrency: true,
      write_concurrency: true
    ])

    update_iteration()

    Enum.each(0..(@num_cols - 1), fn x ->
      Enum.each(0..(@num_rows - 1), fn y ->
        :ets.insert(:button_store, {{x, y}, false})
      end)
    end)
  end

  defp update_iteration() do
    :ets.update_counter(
      :button_store,
      :counter_previous,
      {2, 1, @num_cols - 1, 0},
      {:counter_previous, @num_cols - 2}
    )

    :ets.update_counter(
      :button_store,
      :counter_current,
      {2, 1, @num_cols - 1, 0},
      {:counter_current, -1}
    )
  end
end

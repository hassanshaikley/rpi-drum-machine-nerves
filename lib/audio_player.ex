defmodule RpiDrumMachineNerves.AudioPlayer do
  @moduledoc """
  Audio player that uses a GenServer to manage the audio
  """

  use GenServer

  def start_link(default \\ []), do: GenServer.start_link(__MODULE__, default, name: __MODULE__)

  def init(volume: volume) do
    setup_audio(volume)

    {:ok, synth} = MIDISynth.start_link([])
    {:ok, %{synth: synth}}
  end

  # Public API

  @doc """
  Given a file name, looks for that file in that static folder and plays it

  ## Examples

      iex> AudioPlayer.play_audio("triangle.wav")

  """
  def play_audio(args),
    do: Process.send(__MODULE__, {:play_audio, args}, [])

  # Process.send(__MODULE__, {:play_audio, file}, [])

  @doc """
  Sets volume to the given percent

  ## Examples

      iex> AudioPlayer.set_volume(100)

  """

  def set_volume(percent) when is_integer(percent) and percent in 0..100 do
    spawn(fn ->
      percent
      |> Integer.to_string()
      |> set_volume_cmd
    end)

    percent
  end

  def handle_info({:play_audio, args}, %{synth: synth} = state) do
    apply(MIDISynth.Keyboard, :play, [synth] ++ args)

    {:noreply, state}
  end

  # Private

  defp setup_audio(volume) do
    set_audio_output_to_jack()
    set_volume(volume)
  end

  defp set_audio_output_to_jack do
    try do
      System.cmd("amixer", ["cset", "numid=3", "1"], stderr_to_stdout: true)
    rescue
      e in ErlangError -> "Error!"
    end
  end

  def set_volume_cmd(percent) when is_binary(percent) do
    try do
      System.cmd("amixer", ["cset", "numid=3", "#{percent}%"], stderr_to_stdout: true)
    rescue
      e in ErlangError -> "Error!"
    end
  end
end

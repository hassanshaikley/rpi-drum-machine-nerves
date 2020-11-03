defmodule RpiDrumMachineNerves.AudioPlayer do
  @moduledoc """
  Audio player that uses a GenServer to manage the audio
  """

  @audio_player if(Mix.env() == :prod, do: 'aplay', else: 'afplay')
  @audio_player_cmd if(Mix.env() == :prod, do: '#{@audio_player} -q', else: @audio_player)

  use GenServer

  def start_link(default \\ []), do: GenServer.start_link(__MODULE__, default, name: __MODULE__)

  def init(volume: volume) do
    setup_audio(volume)

    {:ok, []}
  end

  # Public API

  @doc """
  Given a file name, looks for that file in that static folder and plays it

  ## Examples

      iex> AudioPlayer.play_audio("triangle.wav")

  """
  def play_audio(file),
    do: Process.send(__MODULE__, {:play_audio, file}, [])

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

  def handle_info({:play_audio, file}, state) do
    spawn(fn ->
      static_directory_path = Path.join(:code.priv_dir(:drum_machine_nerves), "static")
      full_path = Path.join(static_directory_path, file)

      :os.cmd('#{@audio_player_cmd} #{full_path}')
    end)

    {:noreply, state}
  end

  # Private

  defp setup_audio(volume) do
    set_audio_output_to_jack()
    set_volume(volume)
  end

  # This is expected to fail and do nothing on non rpi devices
  defp set_audio_output_to_jack, do: :os.cmd('amixer cset numid=3 1')

  def set_volume_cmd(percent) when is_binary(percent),
    do: :os.cmd('amixer cset numid=1 #{percent}%')
end

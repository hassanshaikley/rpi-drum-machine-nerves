defmodule AudioPlayer do
  @moduledoc """
  Audio player that uses a GenServer to manage the audio

  Currently unsophisticated; ideally it would schedule things so that the timing is on the dot
  """

  use GenServer
  alias __MODULE__
  @prod Mix.env() == :prod
  # @prod true

  # The library that is going to be used to play audio (on mac afplay, on rpi aplay)
  @audio_player if @prod, do: "aplay", else: "afplay"
  # aplay requires the -q command
  @audio_player_cmd if @prod, do: "#{@audio_player} -q", else: @audio_player

  # The directory where the audio files are stored
  @static_directory_path Path.join(:code.priv_dir(:drum_machine_nerves), "static")

  # GenServer initialization

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(init_arg \\ []) do
    setup_audio()

    {:ok, init_arg}
  end

  # Public API

  @doc """
  Given a file name, looks for that file in that static folder and plays it

  ## Examples

      iex> AudioPlayer.play_sound("triangle.wav")

  """
  def play_sound(file), do: GenServer.cast(__MODULE__, {:play_sound, file})

  @doc """
  Sets volume to the given percent (integer between 0 and 100)

  ## Examples

      iex> AudioPlayer.set_volume("100")

  """

  def set_volume(percent) when is_integer(percent) and percent in 0..100 do
    percent
    |> Integer.to_string()
    |> set_volume_cmd
  end

  @doc """
  Stops any sounds that are currently being played. Used for teardown purposes.
  """
  def stop_sound, do: GenServer.cast(__MODULE__, :stop_audio)

  # GenServer handlers

  def handle_cast(:stop_audio, state) do
    :os.cmd('killall #{@audio_player}')

    {:noreply, state}
  end

  def handle_cast({:play_sound, file}, state) do
    IO.puts "In Play Sound"
    spawn(fn ->
      full_path = Path.join(@static_directory_path, file)

      IO.inspect(full_path)
      IO.inspect('#{@audio_player_cmd} #{full_path}')
      # IO.inspect('#{@audio_player_cmd} #{full_path}')
      :os.cmd('#{@audio_player_cmd} #{full_path}')
    end)

    {:noreply, state}
  end

  # Private

  defp setup_audio do
    # set_audio_output_to_jack()
    set_volume(100)
  end

  # This is expected to fail and do nothing on non rpi devices
  defp set_audio_output_to_jack do
    :os.cmd('amixer cset numid=3 1')
  end

  def set_volume_cmd(percent) when is_binary(percent) do
    :os.cmd('amixer cset numid=1 #{percent}%')
  end
end

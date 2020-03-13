defmodule AudioPlayer do
  use GenServer
  alias __MODULE__

  # The library that is going to be used to play audio (on mac afplay, on rpi aplay)
  @audio_player if Mix.env() == :prod, do: "aplay", else: "afplay"
  # aplay requires the -q command
  @audio_player_cmd if Mix.env() == :prod, do: "#{@audio_player} -q", else: @audio_player

  # The directory where the audio files are stored
  @static_directory_path Path.join(:code.priv_dir(:rpi_drum_machine_nerves), "static")

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
  Given a file name, looks for that file in that static folder and plays it

  ## Examples

      iex> AudioPlayer.play_sound("triangle.wav")

  """
  def play_sound(file), do: GenServer.cast(__MODULE__, {:start_audio, file})

  @doc """
  Stops any sounds that are currently being played. Used for teardown purposes.
  """
  def stop_sound(), do: GenServer.cast(__MODULE__, :stop_audio)

  def handle_cast(:stop_audio, state) do
    :os.cmd('killall #{@audio_player}')

    {:noreply, state}
  end

  # GenServer handlers

  def handle_cast({:start_audio, file}, state) do
    full_path = Path.join(@static_directory_path, file)

    :os.cmd('#{@audio_player_cmd} #{full_path}')

    {:noreply, state}
  end

  # Private

  defp setup_audio() do
    set_audio_output_to_jack()
    set_volume(50)
  end

  defp set_audio_output_to_jack() do
    :os.cmd('amixer cset numid=3 1')
  end

  def set_volume_cmd(percent) when is_binary(percent) do
    :os.cmd('amixer cset numid=1 #{percent}%')
  end
end

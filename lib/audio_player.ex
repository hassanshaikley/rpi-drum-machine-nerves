defmodule AudioPlayer do
  use GenServer
  alias __MODULE__

  @audio_player if Mix.env() == :prod, do: "aplay", else: "afplay"
  @audio_player_cmd if Mix.env() == :prod, do: "#{@audio_player} -q", else: @audio_player
  @static_directory_path Path.join(:code.priv_dir(:rpi_drum_machine_nerves), "static")

  # GenServer initialization

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(init_arg \\ []) do
    setup_rpi_audio()

    {:ok, init_arg}
  end

  # GenServer calls

  def play_sound(file), do: GenServer.cast(__MODULE__, {:start_audio, file})

  def stop_sound(), do: GenServer.cast(__MODULE__, :stop_audio)

  def handle_cast(:stop_audio, state) do
    :os.cmd('killall #{@audio_player}')

    {:noreply, state}
  end

  def set_volume(number) do
    :os.cmd('amixer cset numid=1 #{Integer.to_string(number)}%')
  end

  def handle_cast({:start_audio, file}, state) do
    full_path = Path.join(@static_directory_path, file)

    :os.cmd('#{@audio_player_cmd} #{full_path}')

    {:noreply, state}
  end

  # Private

  defp setup_rpi_audio() do
    set_audio_output_to_jack()
    set_audio_to_50_percent()
  end

  defp set_audio_output_to_jack() do
    :os.cmd('amixer cset numid=3 1')
  end

  defp set_audio_to_50_percent() do
    :os.cmd('amixer cset numid=1 50%')
  end
end

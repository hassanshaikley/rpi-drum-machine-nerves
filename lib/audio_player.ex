defmodule AudioPlayer do
  use GenServer
  alias __MODULE__

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(init_arg \\ []) do
    init_audio()

    # Generates "Hello" audio
    :os.cmd('espeak -ven+f5 -k5 -w /tmp/out.wav Hello')

    {:ok, init_arg}
  end

  def play_sound(file) do
    GenServer.cast(__MODULE__, {:start_audio, file})
  end

  def stop_sound() do
    GenServer.cast(__MODULE__, :stop_audio)
  end

  def handle_cast(:stop_audio, state) do
    :os.cmd('killall afplay')
    :os.cmd('killall aplay')
    {:noreply, state}
  end

  def handle_cast({:start_audio, file}, state) do
    # Works
    static_path = Path.join(:code.priv_dir(:rpi_music_machine_nerves), "static")
    full_path = Path.join(static_path, file)

    spawn(fn -> :os.cmd('aplay -q #{full_path}') end)

    spawn(fn -> :os.cmd('afplay #{full_path}') end)

    {:noreply, state}
  end

  defp init_audio do
    # Sets audio output to jack
    :os.cmd('amixer cset numid=3 1')

    # Sets volume to 60%
    :os.cmd('amixer cset numid=1 50%')
  end
end

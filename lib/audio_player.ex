defmodule AudioPlayer do
  use GenServer
  alias __MODULE__

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(init_arg \\ []) do
    Process.sleep(1500)

    IO.puts("INITIALIZING GENSERVER")

    IO.puts("Setting audio to jack")
    :os.cmd('amixer cset numid=3 1')

    IO.puts("Setting volume to 100%")
    :os.cmd('amixer cset numid=1 100%')

    IO.puts("Generating audio")
    :os.cmd('espeak -ven+f5 -k5 -w /tmp/out.wav Hello')

    IO.puts("Playing audio")
    :os.cmd('aplay -q /tmp/out.wav')

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
    {:noreply, state}
  end

  def handle_cast({:start_audio, file}, state) do
    spawn(fn -> :os.cmd('afplay lib/#{file}') end)

    {:noreply, state}
  end
end

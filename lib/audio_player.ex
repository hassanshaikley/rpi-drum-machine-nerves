defmodule AudioPlayer do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(init_arg \\ []) do
    Process.sleep(1500)

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

  def play_sound(pid) do
    GenServer.call(__MODULE__, :play_sound)
  end

  def handle_cast(:play_sound, state) do
    IO.puts("PLAYING SOUND")
    :os.cmd('afplay -q cello.wav') |> IO.inspect()

    {:noreply, state}
  end
end

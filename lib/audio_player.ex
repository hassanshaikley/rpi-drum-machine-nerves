defmodule AudioPlayer do
  use GenServer
  alias __MODULE__

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(init_arg \\ []) do
    init_audio()

    {:ok, init_arg}
  end

  def play_sound(file) do
    GenServer.cast(__MODULE__, {:start_audio, file})
  end

  def stop_sound() do
    GenServer.cast(__MODULE__, :stop_audio)
  end

  def handle_cast(:stop_audio, state) do
    case Mix.env() == :prod do
      true -> :os.cmd('killall aplay')
      false -> :os.cmd('killall afplay')
    end

    {:noreply, state}
  end

  def handle_cast({:start_audio, file}, state) do
    static_path = Path.join(:code.priv_dir(:rpi_music_machine_nerves), "static")
    full_path = Path.join(static_path, file)

    case Mix.env() == :prod do
      true -> spawn(fn -> :os.cmd('aplay -q #{full_path}') end)
      false -> spawn(fn -> :os.cmd('afplay #{full_path}') end)
    end

    {:noreply, state}
  end

  defp init_audio do
    # Sets audio output to jack
    :os.cmd('amixer cset numid=3 1')
    :os.cmd('amixer cset numid=1 50%')
  end

  def set_volume(number) do
    # Sets volume to 60%
    :os.cmd('amixer cset numid=1 #{Integer.to_string(number)}%')
  end
end

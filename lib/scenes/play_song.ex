defmodule RpiMusicMachineNerves.Scene.PlaySong do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives
  import Scenic.Primitive.Text

  @fps 10
  @screen_width 800

  #   @in_the_aeroplane "What a beautiful face I have found in this place That is circling all round the sun What a beautiful dream That could flash on the screen In a blink of an eye and be gone from me  Soft and sweet Let me hold it close and keep it here with me  And one day we will die And our ashes will fly From the aeroplane over the sea But for now we are young Let us lay in the sun And count every beautiful thing we can see  Love to be In the arms of all I'm keeping here with me  What a curious life We have found here tonight There is music that sounds from the street There are lights in the clouds Anna's ghost all around Hear her voice as it's rolling and ringing through me  Soft and sweet How the notes all bend and reach above the trees  Now how I remember you How I would push my fingers through Your mouth to make those muscles move That made your voice so smooth and sweet But now we keep where we don't know All secrets sleep in winter clothes With the one you loved so long ago Now he don't even know his name  What a beautiful face I have found in this place That is circling all 'round the sun And when we meet on a cloud I'll be laughing out loud I'll be laughing with everyone I see  Can't believe How strange it is to be anything at all"
  @in_the_aeroplane [
    [text: "what a beautiful face", start_time: 1000, note: :c],
    [text: "I have found in this place", start_time: 4000, time_end: ~T[01:00:07.001], note: :c]
  ]
  @graph Graph.build(font_size: 22, font: :roboto_mono)
         #  |> group(
         #    fn g ->
         #      g
         #      |> text("Hello friend Playing song", translate: {10, 20}, font_size: 18)
         #    end,
         #    t: {10, 30}
         #  )
         #  |> text("Hi", id: :hi, translate: {50, 80})
         |> text("CURRENT LYRIC FIELD", id: :current_lyric, translate: {150, 80})
         |> Map.put(:current_lyric_index, 0)

  # --------------------------------------------------------
  def init(_, opts) do
    {:ok, info} = Scenic.ViewPort.info(opts[:viewport])

    IO.puts("Scheduling work!")
    schedule_work()

    Enum.each(@in_the_aeroplane, fn lyric ->
      start_time = Keyword.get(lyric, :start_time)
      IO.puts("Sending after")
      IO.inspect(start_time)
      Process.send_after(self(), :show_next_lyric, start_time)
    end)

    spawn(fn -> :os.cmd('afplay lib/in_the_airplane_over_the_sea_karaoke.mp3 ') end)

    {:ok, @graph, push: @graph}
  end

  def handle_info(:show_next_lyric, graph) do
    current_lyric = Enum.at(@in_the_aeroplane, graph.current_lyric_index)

    current_lyric_text = Keyword.get(current_lyric, :text)
    graph = Map.put(graph, :current_lyric_index, graph.current_lyric_index + 1)

    graph =
      graph
      |> Graph.modify(:current_lyric, &text(&1, current_lyric_text))

    IO.puts("Putting poop")

    {:noreply, graph, push: graph}
  end

  @impl true
  def handle_info(:work, state) do
    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, Kernel.trunc(1000 / @fps))
  end

  # works on MAC dev env
  defp stop_audio() do
    :os.cmd('killall afplay')
  end

  defp text_speed_x() do
    @screen_width / @fps
  end
end

defmodule RpiMusicMachineNerves.Scene.Crosshair do
  use Scenic.Scene

  alias Scenic.ViewPort
  alias Scenic.Graph
  alias Scenic.Primitive
  import Scenic.Primitives
  import Scenic.Components

  @width 10000
  @height 10000

  @graph Graph.build(font: :roboto, font_size: 16)
         |> rect({@width, @height}, id: :background)
         |> text("Touch the screen to start", id: :pos, translate: {20, 80})
         |> line({{0, 100}, {@width, 100}}, stroke: {4, :white}, id: :cross_hair_h, hidden: true)
         |> line({{100, 0}, {100, @height}}, stroke: {4, :white}, id: :cross_hair_v, hidden: true)
         |> button("Start", id: :play_song, translate: {20, 180})

  @song_playing_graph Graph.build(font: :roboto, font_size: 16)
                      |> rect({@width, @height}, id: :background)
                      |> text("Song Playing or something", id: :pos, translate: {20, 80})
                      |> button("Stop", id: :stop_song, translate: {20, 180})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _) do
    {:ok, @graph, push: @graph}
  end

  # ============================================================================
  # event handlers

  def filter_event({:click, :play_song}, context, state) do
    IO.puts("HITTING AUD PLAY")
    AudioPlayer.play_sound()

    {:noreply, @song_playing_graph, push: @song_playing_graph}
  end

  def filter_event({:click, :stop_song}, context, state) do
    IO.puts("HITTING AUD stop")
    AudioPlayer.stop_sound()

    {:noreply, @song_playing_graph, push: @song_playing_graph}
  end

  def handle_input(_msg, _, graph) do
    {:noreply, graph}
  end
end

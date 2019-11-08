defmodule RpiMusicMachineNerves.Scene.Crosshair do
  use Scenic.Scene

  alias Scenic.ViewPort
  alias Scenic.Graph
  alias Scenic.Primitive
  import Scenic.Primitives
  import Scenic.Components

  @width 10000
  @height 10000

  @main_menu_graph Graph.build(font: :roboto, font_size: 16)
                   |> rect({@width, @height}, id: :background)
                   |> button("Start Song", id: :play_song, translate: {20, 430})

  @song_playing_graph Graph.build(font: :roboto, font_size: 16)
                      |> rect({@width, @height}, id: :background)
                      |> text("~~ In The Aeroplane Over The Sea ~~",
                        id: :title,
                        translate: {400, 50},
                        text_align: :center,
                        font_size: 40
                      )
                      |> text("",
                        id: :current_lyric,
                        translate: {400, 200},
                        text_align: :center,
                        font_size: 36
                      )
                      |> Map.put(:current_lyric_index, 0)
                      |> button("Stop Song", id: :stop_song, translate: {20, 430})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _) do
    {:ok, @main_menu_graph, push: @main_menu_graph}
  end

  # ============================================================================
  # event handlers

  # --------------------------------------------------------
  def filter_event({:click, :play_song}, context, state) do
    AudioPlayer.play_sound()
    {:noreply, @song_playing_graph, push: @song_playing_graph}
  end

  def filter_event({:click, :stop_song}, context, state) do
    AudioPlayer.stop_sound()
    {:noreply, @main_menu_graph, push: @main_menu_graph}
  end

  def handle_input(_msg, _, graph) do
    {:noreply, graph}
  end

  # ============================================================================
  # rendering helpers

  # --------------------------------------------------------
  def show_next_text() do
  end
end

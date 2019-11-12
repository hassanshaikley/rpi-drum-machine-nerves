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
                   #  |> button(" ", id: :xy, translate: {20, 20})
                   |> group(
                     fn graph ->
                       group = Primitive.Group.build()

                       y = 0
                       x = 1

                       Enum.reduce([{50, 100, 00}, {100, 100, 01}, {150, 100, 02}], graph, fn obj,
                                                                                              graph ->
                         x = elem(obj, 0)
                         y = elem(obj, 1)
                         label = elem(obj, 2)

                         text(graph, "#{label}", translate: {x, y})
                       end)

                       #  graph
                       #  #  |> button("00", translate: {0, 20})
                       #  #  |> button("01", translate: {50, 20})
                       #  |> Graph.add(group)
                     end,
                     t: {10, 110}
                   )

  @song_playing_graph Graph.build(font: :roboto, font_size: 16)
                      |> rect({@width, @height}, id: :background)
  # |> button("Stop Song", id: :stop_song, translate: {20, 430})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _) do
    # loop()
    {:ok, @main_menu_graph, push: @main_menu_graph}
  end

  # ============================================================================
  # event handlers

  # --------------------------------------------------------
  def filter_event({:click, :play_song}, context, state) do
    # AudioPlayer.play_sound()
    {:noreply, @song_playing_graph, push: @song_playing_graph}
  end

  def filter_event({:click, :stop_song}, context, state) do
    # AudioPlayer.stop_sound()
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

  # @impl true
  # def handle_info(:loop, state) do
  #   # Reschedule once more
  #   loop()
  #   IO.puts("LOOPING")

  #   {:noreply, state}
  # end

  # defp loop do
  #   Process.send_after(self(), :loop, Kernel.trunc(1000 / @fps))
  # end
end

defmodule RpiMusicMachineNerves.Scene.PlaySong do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives

  @graph Graph.build(font_size: 22, font: :roboto_mono)
         |> group(
           fn g ->
             g
             |> text("Hello friend Playing song", translate: {10, 20}, font_size: 18)
           end,
           t: {10, 30}
         )
         |> group(
           fn g ->
             g
             |> text("ViewPort")
             |> text("", translate: {10, 20}, font_size: 18, id: :vp_info)
           end,
           t: {10, 110}
         )
         |> group(
           fn g ->
             g
             |> text("Devices are being loaded...",
               translate: {10, 20},
               font_size: 18,
               id: :devices
             )
           end,
           t: {280, 30},
           id: :device_list
         )

  # --------------------------------------------------------
  def init(_, opts) do
    {:ok, info} = Scenic.ViewPort.info(opts[:viewport])

    vp_info = """
    size: #{inspect(Map.get(info, :size))}
    """

    # styles: #{stringify_map(Map.get(info, :styles, %{a: 1, b: 2}))}
    # transforms: #{stringify_map(Map.get(info, :transforms, %{}))}
    # drivers: #{stringify_map(Map.get(info, :drivers))}

    graph =
      @graph
      |> Graph.modify(:vp_info, &text(&1, vp_info))
      |> Graph.modify(:device_list, &update_opts(&1, hidden: @target == "host"))

    {:ok, graph, push: graph}
  end
end

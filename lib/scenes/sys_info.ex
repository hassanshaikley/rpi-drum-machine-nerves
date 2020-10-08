defmodule DrumMachineNerves.Scene.SysInfo do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives

  @target System.get_env("MIX_TARGET") || "host"

  @system_info """
  MIX_TARGET: #{@target}
  MIX_ENV: #{Mix.env()}
  Scenic version: #{Scenic.version()}
  """

  @iex_note """
  Please note: because Scenic
  draws over the entire screen
  in Nerves, IEx has been routed
  to the UART pins.
  """

  @graph Graph.build(font_size: 22, font: :roboto_mono)
         |> group(
           fn g ->
             g
             |> text("System")
             |> text(@system_info, translate: {10, 20}, font_size: 18)
           end,
           t: {10, 30}
         )
         |> group(
           fn g ->
             g
             |> text("File Info")
             |> text("", translate: {10, 20}, font_size: 18, id: :file_info)
           end,
           t: {10, 110}
         )
         |> group(
           fn g ->
             g
             |> text("Device List")
             |> text("", translate: {10, 20}, font_size: 18, id: :device_list)
           end,
           t: {10, 180}
         )
         |> group(
           fn g ->
             g
             |> text("IEx")
             |> text(@iex_note, translate: {10, 20}, font_size: 18)
           end,
           t: {10, 240}
         )

  # --------------------------------------------------------
  def init(_, opts) do
    {:ok, info} = Scenic.ViewPort.info(opts[:viewport])

    file_info = """
    size: #{inspect(Map.get(info, :size))}
    """

    # styles: #{stringify_map(Map.get(info, :styles, %{a: 1, b: 2}))}
    # transforms: #{stringify_map(Map.get(info, :transforms, %{}))}
    # drivers: #{stringify_map(Map.get(info, :drivers))}

    graph =
      @graph
      |> Graph.modify(:file_info, &text(&1, file_info))

    # unless @target == "host" do
    # subscribe to the simulated temperature sensor
    Process.send_after(self(), :loop, 100)
    # end

    {:ok, graph, push: graph}
  end

  def handle_info(:loop, graph) do
    Process.send_after(self(), :loop, 500)
    x = :rand.uniform(10)

    if x == 5 do
      IO.puts("Playing audio")
      AudioPlayer.play_sound("triangle.wav")

      # :os.cmd('espeak -ven+f5 -k5 -w /tmp/out.wav Hello')
      # :os.cmd('aplay -q /tmp/out.wav')
    end

    static_path = Path.join(:code.priv_dir(:drum_machine_nerves), "static")
    files = File.ls(static_path) |> elem(1) |> to_string

    output = static_path <> "\n" <> files

    static_directory_path = Path.join(:code.priv_dir(:drum_machine_nerves), "static")
    full_path = Path.join(static_directory_path, "snare.wav")
    device_list = :os.cmd('aplay -q #{full_path}') |> to_string() |> IO.inspect()

    graph =
      graph
      |> Graph.modify(:file_info, &text(&1, output))
      |> Graph.modify(:device_list, &text(&1, device_list))

    IO.puts("3")

    {:noreply, graph, push: graph}
  end
end

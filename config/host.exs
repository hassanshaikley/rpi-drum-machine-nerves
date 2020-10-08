use Mix.Config

config :drum_machine_nerves, :viewport, %{
  name: :main_viewport,
  # default_scene: {DrumMachineNerves.Scene.Crosshair, nil},
  default_scene: {DrumMachineNerves.Scene.Main, nil},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :drum_machine_nerves"]
    }
  ]
}

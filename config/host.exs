use Mix.Config

config :rpi_drum_machine_nerves, :viewport, %{
  name: :main_viewport,
  # default_scene: {RpiDrumMachineNerves.Scene.PlaySong, nil},
  default_scene: {RpiDrumMachineNerves.Scene.Main, nil},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :rpi_drum_machine_nerves"]
    }
  ]
}

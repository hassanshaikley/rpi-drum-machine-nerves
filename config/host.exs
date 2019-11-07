use Mix.Config

config :rpi_music_machine_nerves, :viewport, %{
  name: :main_viewport,
  # default_scene: {RpiMusicMachineNerves.Scene.PlaySong, nil},
  default_scene: {RpiMusicMachineNerves.Scene.Crosshair, nil},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :rpi_music_machine_nerves"]
    }
  ]
}

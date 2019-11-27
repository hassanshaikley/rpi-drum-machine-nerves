use Mix.Config

config :rpi_music_machine_nerves, :viewport, %{
  name: :main_viewport,
  # default_scene: {RpiMusicMachineNerves.Scene.PlaySong, nil},
  default_scene: {RpiMusicMachineNerves.Scene.Main, nil},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Nerves.Rpi
    },
    %{
      module: Scenic.Driver.Nerves.Touch,
      opts: [
        device: "FT5406 memory based driver",
        calibration: {{1, 0, 0}, {1, 0, 0}}
      ]
    }
  ]
}

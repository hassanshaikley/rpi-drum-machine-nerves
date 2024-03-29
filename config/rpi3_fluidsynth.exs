use Mix.Config

config :drum_machine_nerves, :viewport, %{
  name: :main_viewport,
  # default_scene: {RpiDrumMachineNerves.Scene.Crosshair, nil},
  default_scene: {RpiDrumMachineNerves.Scene.Main, nil},
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

config :power_control,
  cpu_governor: :powersave,
  disable_hdmi: true,
  disable_leds: true

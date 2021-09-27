Benchee.run(
  %{
    "non-meta" => fn -> RpiDrumMachineNerves.Components.VolumeControls.volume_string_slow(1) end,
    "meta" => fn -> RpiDrumMachineNerves.Components.VolumeControls.volume_string(1)  end
  },
  time: 10,
  memory_time: 2
)

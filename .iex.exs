alias RpiDrumMachineNerves.Components.VolumeControls

volume_text_macro = fn x ->

  VolumeControls.volume_text_macro(x)
end


volume_text = fn x ->

  VolumeControls.volume_text(x)
end

# Benchee.run(
#   %{
#     "rem" => fn -> rem(1 + 1, 8) end,
#     "match" => fn -> RpiDrumMachineNerves.Optimizations.get_next_iteration(0) end
#   },
#   time: 10,
#   memory_time: 2
# )




Benchee.run(
  %{
    "without macro" => fn -> volume_text.(10) end,
    "with macro" => fn -> volume_text_macro.(10) end
  },
  time: 10,
  memory_time: 2
)

# IO.puts "HI"

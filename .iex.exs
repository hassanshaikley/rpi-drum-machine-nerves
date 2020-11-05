thing = fn 0 -> 1 end

Benchee.run(
  %{
    "rem" => fn -> rem(1 + 1, 8) end,
    "match" => fn -> RpiDrumMachineNerves.Optimizations.get_next_iteration(0) end
  },
  time: 10,
  memory_time: 2
)

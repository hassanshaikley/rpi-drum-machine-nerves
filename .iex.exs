a = "cat"
b = "dog"

thing = fn 0, 0 -> :"0_0" end

Benchee.run(
  %{
    a == b
    end,
    a === b
    end
  },
  time: 10,
  memory_time: 2
)

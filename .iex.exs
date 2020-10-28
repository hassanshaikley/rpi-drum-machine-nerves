a = "cat"
b = "dog"

thing = fn 0, 0 -> :"0_0" end

Benchee.run(
  %{
    "Matching" => fn ->
      thing.(0, 0)
    end,
    "Concatenation" => fn ->
      s = a <> b
      String.to_atom(s)
    end
  },
  time: 10,
  memory_time: 2
)

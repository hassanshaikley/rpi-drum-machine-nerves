Readme text goes here

From template

# Perf things

```
a = "cat"
b = "dog"

Benchee.run(
  %{
    "Interpolation" => fn ->
      "#{a}#{b}"
    end,
    "Concatenation" => fn ->
      a <> b
    end
  },
  time: 10,
  memory_time: 2
)
```

```
Name                    ips        average  deviation         median         99th %
Concatenation      817.95 K        1.22 μs  ±2576.49%           1 μs           3 μs
Interpolation      258.23 K        3.87 μs   ±636.15%           3 μs           6 μs

Comparison:
Concatenation      817.95 K
Interpolation      258.23 K - 3.17x slower +2.65 μs

Memory usage statistics:

Name             Memory usage
Concatenation         0.99 KB
Interpolation         2.32 KB - 2.34x memory usage +1.33 KB
```

Then theres matching

```
Benchmarking Concatenation...
Benchmarking Matching...

Name                    ips        average  deviation         median         99th %
Matching             1.32 M        0.76 μs  ±6499.33%        0.98 μs        0.98 μs
Concatenation        0.41 M        2.42 μs  ±1364.84%        1.98 μs        3.98 μs

Comparison:
Matching             1.32 M
Concatenation        0.41 M - 3.19x slower +1.66 μs

Memory usage statistics:

Name             Memory usage
Matching              0.45 KB
Concatenation         1.62 KB - 3.57x memory usage +1.16 KB
```

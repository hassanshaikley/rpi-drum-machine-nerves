https://github.com/devonestes/fast-elixir#map-lookup-vs-pattern-matching-lookup-code



#### FIRST BENCHMARK

Benchmark One

    Benchee.run(
      %{
        "map put" => fn ->
          Map.put(%{x: 1, y: 2}, :y, 1)
        end,
        "map other thing" => fn ->

          m = %{x: 1, y: 2}
          %{m | y: 1}
        end, 
      },
      print: [benchmarking: false]
    )

Name                      ips        average  deviation         median         99th %
map put               12.26 M       81.54 ns ±34653.99%           0 ns           0 ns
map other thing        8.27 M      120.96 ns ±20423.98%           0 ns        1000 ns

Comparison: 
map put               12.26 M
map other thing        8.27 M - 1.48x slower +39.42 ns
%Benchee.Suite{

#### SECOND BENCHMARK

    Benchee.run(
      %{
        "button old" => fn ->
          button_width = 45
button_height = 45
button_padding = 2
cols = 6
           Enum.map(0..cols, fn x ->
             {(button_width + button_padding) * x, button_padding, Integer.to_string(x) <> "0"}
           end) 
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x,
                button_height + button_padding + button_padding, Integer.to_string(x) <> "1"}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 2 + button_padding * 3,
                Integer.to_string(x) <> "2"}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 3 + button_padding * 4,
                Integer.to_string(x) <> "3"}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 4 + button_padding * 5,
                Integer.to_string(x) <> "4"}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 5 + button_padding * 6,
                Integer.to_string(x) <> "5"}
             end)


        end,
        "button new" => fn ->
button_width = 45
button_height = 45
button_padding = 2
cols = 6

    [
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_padding,
                Integer.to_string(x) <> "0"}
             end)
             | [
                 Enum.map(0..cols, fn x ->
                   {(button_width + button_padding) * x,
                    button_height + button_padding + button_padding,
                    Integer.to_string(x) <> "1"}
                 end)
                 | [
                     Enum.map(0..cols, fn x ->
                       {(button_width + button_padding) * x,
                        button_height * 2 + button_padding * 3, Integer.to_string(x) <> "2"}
                     end)
                     | [
                         Enum.map(0..cols, fn x ->
                           {(button_width + button_padding) * x,
                            button_height * 3 + button_padding * 4, Integer.to_string(x) <> "3"}
                         end)
                         | [
                             Enum.map(0..cols, fn x ->
                               {(button_width + button_padding) * x,
                                button_height * 4 + button_padding * 5,
                                Integer.to_string(x) <> "4"}
                             end)
                             | [
                                 Enum.map(0..cols, fn x ->
                                   {(button_width + button_padding) * x,
                                    button_height * 5 + button_padding * 6,
                                    Integer.to_string(x) <> "5"}
                                 end)
                               ]
                           ]
                       ]
                   ]
               ]
           ]
           |> List.flatten()
        end, 
      },
      print: [benchmarking: false]
    )



#### Third BENCHMARK

    Benchee.run(
      %{
        "button old" => fn ->
          button_width = 45
button_height = 45
button_padding = 2
cols = 6
           Enum.map(0..cols, fn x ->
             {(button_width + button_padding) * x, button_padding, Integer.to_string(x) <> "0"}
           end) 
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x,
                button_height + button_padding + button_padding, Integer.to_string(x) <> "1"}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 2 + button_padding * 3,
                Integer.to_string(x) <> "2"}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 3 + button_padding * 4,
                Integer.to_string(x) <> "3"}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 4 + button_padding * 5,
                Integer.to_string(x) <> "4"}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 5 + button_padding * 6,
                Integer.to_string(x) <> "5"}
             end)


        end,
        "button new" => fn ->
button_width = 45
button_height = 45
button_padding = 2
cols = 6


           Enum.map(0..cols, fn x ->
             {(button_width + button_padding) * x, button_padding, to_string(Integer.to_charlist(x) ++ '0')}
           end) 
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x,
                button_height + button_padding + button_padding, to_string(Integer.to_charlist(x) ++ '1')}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 2 + button_padding * 3,
                to_string(Integer.to_charlist(x) ++ '2')}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 3 + button_padding * 4,
                to_string(Integer.to_charlist(x) ++ '3')}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 4 + button_padding * 5,
                to_string(Integer.to_charlist(x) ++ '4')}
             end) ++
             Enum.map(0..cols, fn x ->
               {(button_width + button_padding) * x, button_height * 5 + button_padding * 6,
                to_string(Integer.to_charlist(x) ++ '5')}
             end)

        end, 
      },
      print: [benchmarking: false]
    )



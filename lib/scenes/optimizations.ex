defmodule DrumMachineNerves.Optimizations do
  def encode_iteration_row(0, 0), do: :"0_0"
  def encode_iteration_row(0, 1), do: :"0_1"
  def encode_iteration_row(0, 2), do: :"0_2"
  def encode_iteration_row(0, 3), do: :"0_3"
  def encode_iteration_row(0, 4), do: :"0_4"

  def encode_iteration_row(1, 0), do: :"1_0"
  def encode_iteration_row(1, 1), do: :"1_1"
  def encode_iteration_row(1, 2), do: :"1_2"
  def encode_iteration_row(1, 3), do: :"1_3"
  def encode_iteration_row(1, 4), do: :"1_4"

  def encode_iteration_row(2, 0), do: :"2_0"
  def encode_iteration_row(2, 1), do: :"2_1"
  def encode_iteration_row(2, 2), do: :"2_2"
  def encode_iteration_row(2, 3), do: :"2_3"
  def encode_iteration_row(2, 4), do: :"2_4"

  def encode_iteration_row(3, 0), do: :"3_0"
  def encode_iteration_row(3, 1), do: :"3_1"
  def encode_iteration_row(3, 2), do: :"3_2"
  def encode_iteration_row(3, 3), do: :"3_3"
  def encode_iteration_row(3, 4), do: :"3_4"

  def encode_iteration_row(4, 0), do: :"4_0"
  def encode_iteration_row(4, 1), do: :"4_1"
  def encode_iteration_row(4, 2), do: :"4_2"
  def encode_iteration_row(4, 3), do: :"4_3"
  def encode_iteration_row(4, 4), do: :"4_4"

  def encode_iteration_row(5, 0), do: :"5_0"
  def encode_iteration_row(5, 1), do: :"5_1"
  def encode_iteration_row(5, 2), do: :"5_2"
  def encode_iteration_row(5, 3), do: :"5_3"
  def encode_iteration_row(5, 4), do: :"5_4"

  def encode_iteration_row(6, 0), do: :"6_0"
  def encode_iteration_row(6, 1), do: :"6_1"
  def encode_iteration_row(6, 2), do: :"6_2"
  def encode_iteration_row(6, 3), do: :"6_3"
  def encode_iteration_row(6, 4), do: :"6_4"

  def encode_iteration_row(7, 0), do: :"7_0"
  def encode_iteration_row(7, 1), do: :"7_1"
  def encode_iteration_row(7, 2), do: :"7_2"
  def encode_iteration_row(7, 3), do: :"7_3"
  def encode_iteration_row(7, 4), do: :"7_4"

  def encode_iteration_row(8, 0), do: :"8_0"
  def encode_iteration_row(8, 1), do: :"8_1"
  def encode_iteration_row(8, 2), do: :"8_2"
  def encode_iteration_row(8, 3), do: :"8_3"
  def encode_iteration_row(8, 4), do: :"8_4"

  def encode_iteration_row(iteration, row) do
    "#{iteration}_#{row}" |> IO.inspect()
  end
end
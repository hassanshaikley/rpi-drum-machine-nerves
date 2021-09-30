defmodule RpiDrumMachineNerves.Optimizations do
  @doc """
  Given two numbers it concatenates them between _and returns them as an atom.
  This is the translation from two numbers to an id used in this app.

  ## Examples

      iex> Optimizations.encode_iteration_row(5, 0)
      :"5_0"

  """

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

  def get_next_iteration(iteration) when iteration == 0, do: 1
  def get_next_iteration(iteration) when iteration == 1, do: 2
  def get_next_iteration(iteration) when iteration == 2, do: 3
  def get_next_iteration(iteration) when iteration == 3, do: 4
  def get_next_iteration(iteration) when iteration == 4, do: 5
  def get_next_iteration(iteration) when iteration == 5, do: 6
  def get_next_iteration(iteration) when iteration == 6, do: 7
  def get_next_iteration(iteration) when iteration == 7, do: 0

  def get_previous_iteration(iteration) when iteration == 0, do: 7
  def get_previous_iteration(iteration) when iteration == 1, do: 0
  def get_previous_iteration(iteration) when iteration == 2, do: 1
  def get_previous_iteration(iteration) when iteration == 3, do: 2
  def get_previous_iteration(iteration) when iteration == 4, do: 3
  def get_previous_iteration(iteration) when iteration == 5, do: 4
  def get_previous_iteration(iteration) when iteration == 6, do: 5
  def get_previous_iteration(iteration) when iteration == 7, do: 6

  # Drawn from https://github.com/cjfreeze/power_control
  # Just to reduce power consumption
  def disable_hdmi do
    case Mix.env() do
      :prod -> System.cmd("tvservice", ["-o"])
      _ -> :noop
    end
  end

  # Still need to test that this work
  def disable_ethernet do
    case Mix.env() do
      :prod -> System.cmd("echo", ["ip", "link", "set", "eth0", "down"])
      _ -> :noop
    end
  end

  def disable_usb do
    case Mix.env() do
      :prod -> System.cmd("echo", ["0x0", ">", "/sys/devices/platform/bcm2708_usb/buspower"])
      _ -> :noop
    end
  end
end

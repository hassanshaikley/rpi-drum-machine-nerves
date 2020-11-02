defmodule RpiDrumMachineNerves.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @target Mix.target()

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SnTest.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children("host") do
    main_viewport_config = Application.get_env(:drum_machine_nerves, :viewport)

    [
      {Scenic, viewports: [main_viewport_config]},
      {AudioPlayer, [volume: 50]}
    ]
  end

  def children(_target) do
    main_viewport_config = Application.get_env(:drum_machine_nerves, :viewport)

    [
      {Scenic, viewports: [main_viewport_config]},
      {AudioPlayer, [volume: 50]}
    ]
  end
end

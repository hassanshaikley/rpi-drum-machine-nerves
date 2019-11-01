defmodule RpiMusicMachineNerves.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.target()

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SnTest.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children("host") do
    main_viewport_config = Application.get_env(:rpi_music_machine_nerves, :viewport)

    [
      {Scenic, viewports: [main_viewport_config]},
      {AudioPlayer, []}
    ]
  end

  def children(_target) do
    main_viewport_config = Application.get_env(:rpi_music_machine_nerves, :viewport)

    [
      {Scenic, viewports: [main_viewport_config]},
      {AudioPlayer, []}
    ]
  end
end

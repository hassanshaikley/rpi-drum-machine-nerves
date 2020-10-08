defmodule AudioPlayer2 do
  def play_sound(file) do
    static_directory_path = Path.join(:code.priv_dir(:drum_machine_nerves), "static")
    full_path = Path.join(static_directory_path, file)
    :os.cmd('#{audio_player_cmd} #{full_path}')

    :noop
  end

  defp prod, do: Mix.env() == :prod
  defp audio_player, do: if(prod, do: "aplay", else: "afplay")
  defp audio_player_cmd, do: if(prod, do: "#{audio_player} -q", else: "#{audio_player}")
end

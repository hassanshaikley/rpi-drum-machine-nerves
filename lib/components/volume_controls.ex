defmodule RpiDrumMachineNerves.Components.VolumeControls do
  @moduledoc """
  Volume Slider component
  """

  use Scenic.Component, has_children: true
  import Scenic.{Components, Primitives}

  alias Scenic.Graph

  @graph Graph.build(font: :roboto_mono, font_size: 16)
         |> group(
           fn graph ->
             graph
             |> text("vol\n(50)", t: {0, 0}, id: :volume_label)
             |> button("+",
               theme: %{
                 text: :white,
                 background: {100, 100, 100},
                 active: {100, 200, 100},
                 border: :black
               },
               id: :volume_up,
               t: {40, -10},
               height: 70,
               width: 70
             )
             |> button("-",
               theme: %{
                 text: :white,
                 background: {100, 100, 100},
                 active: {100, 200, 100},
                 border: :black
               },
               id: :volume_down,
               t: {40, -10 + 80},
               height: 70,
               width: 70
             )
           end,
           t: {630, 300}
         )

  def init(_, _opts) do
    state = %{
      graph: @graph
    }

    {:ok, state, push: state.graph}
  end

  def verify(_), do: {:ok, nil}

  def handle_cast({:update_volume, new_volume}, state) do
    graph = Graph.modify(state.graph, :volume_label, &text(&1, volume_text(new_volume)))
    {:noreply, state, push: graph}
  end


  def child_spec({args, opts}) do
    %{
      id: make_ref(),
      start:
        {Scenic.Scene, :start_link, [__MODULE__, args, Keyword.put_new(opts, :name, __MODULE__)]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end



  def volume_text(vol) do
    vol = Integer.to_string(vol)
    "vol\n(" <> vol <> ")"
  end

  # def unquote(:"hello_#{name}")() do
  #   IO.inspect("Hello #{unquote(name)}")
  # end

  # First attempt
  # 0..100 |> Enum.each fn vol ->
  #   def volume_text_macro(unquote(vol)) do
  #     vol_string = to_string(unquote(vol))
  #     "vol\n(" <> vol_string <> ")"
  #   end
  # end

  # 0..0 |> Enum.each fn vol ->
  #   defmacro volume_text_macro(unquote(vol) = vol) do
  #     quote do
  #       # MyOtherModule.unquote(action)(unquote(msg), unquote(sender))

  #       "vol\n(" <>  unquote(vol) <> ")"
  #     end
  #   end
  # end
  # for vol <- 0..100 do
  #   def volume_text_macro(unquote(vol)) do
  #     vol = Integer.to_string(vol)

  #     unquote("vol\n(#{vol})")
  #   end
  # end

  def volume_text_macro(10) do
    "vol\n(10)"
  end
  # for i <- 0..100 do
  #   def unquote(:volume_text_macro)(unquote(i)) do
  #     vol = Integer.to_string(unquote(i))
  #     string = "vol\n(#{vol})"
  #     string
  #   end
  # end

end

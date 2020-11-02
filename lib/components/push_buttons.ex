defmodule RpiDrumMachineNerves.Components.PushButtons do
  @moduledoc """
  Push Buttons component

  With scenic we use two buttons to create the illusion of changing a buttons color.
  When a button is pressed, it is hidden and the opposite state button that sits directly
  underneath it is revealed.
  """

  # use Scenic.Scene, has_children: false
  use Scenic.Component, has_children: true

  import Scenic.{Components, Primitives}

  alias Scenic.{Graph, Primitive}

  @num_rows 5
  @num_cols 8

  @button_width 60
  @button_height @button_width
  @button_padding 4

  # Tuples for every button containing {the left most x value, the top most y value, and the unique button id}
  # This is only used to build the UI
  @buttons Enum.map(0..(@num_cols - 1), fn x ->
             Enum.map(0..(@num_rows - 1), fn y ->
               {(@button_width + @button_padding) * x, (@button_height + @button_padding) * y,
                {x, y}}
             end)
           end)
           |> List.flatten()

  # anonymouse function so that I can call it from the module attribute / cache the graph at compile time
  push_button = fn graph, obj, button_width, button_height, direction, background ->
    x = elem(obj, 0)
    y = elem(obj, 1)
    label = elem(obj, 2)
    id = Tuple.append(label, direction)
    # Initialize the down (pressed) button as hidden
    hidden = direction == :down

    button(graph, "",
      theme: %{
        text: :white,
        background: background,
        active: background,
        border: :green
      },
      hidden: hidden,
      id: id,
      translate: {x, y},
      height: button_height,
      width: button_width
    )
  end

  @graph Graph.build()
         |> group(
           fn graph ->
             Enum.reduce(
               @buttons,
               graph,
               fn obj, graph ->
                 graph
                 |> push_button.(
                   obj,
                   @button_width,
                   @button_height,
                   :up,
                   {200, 200, 200}
                 )
                 |> push_button.(
                   obj,
                   @button_width,
                   @button_height,
                   :down,
                   {50, 240, 50}
                 )
               end
             )
           end,
           t: {16, 140}
         )

  def init(
        _,
        _opts
      ) do
    graph = @graph

    state = %{
      graph: graph
    }

    {:ok, state, push: graph}
  end

  def verify(_), do: {:ok, nil}

  def filter_event({:click, {_col, _row, :up} = id} = event, _context, state) do
    graph = toggle_button(id, true, state.graph)
    state = Map.put(state, :graph, graph)

    {:cont, event, state, push: graph}
  end

  def filter_event({:click, {_col, _row, :down} = id} = event, _context, state) do
    graph = toggle_button(id, false, state.graph)
    state = Map.put(state, :graph, graph)

    {:cont, event, state, push: graph}
  end

  # In scenic to show that a button is down you need two buttons
  # One for how it looks when it is up and another for how it looks when it is down
  # And then hide the inactive button
  defp toggle_button({col, row, _down}, button_down, state) do
    state
    |> Graph.modify({col, row, :down}, fn p ->
      Primitive.put_style(p, :hidden, !button_down)
    end)
    |> Graph.modify({col, row, :up}, fn p ->
      Primitive.put_style(p, :hidden, button_down)
    end)
  end
end

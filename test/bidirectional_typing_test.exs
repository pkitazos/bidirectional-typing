defmodule BidirectionalTypingTest do
  use ExUnit.Case
  alias BidirectionalTyping, as: BT
  doctest BT

  @bool :bool
  # ^ kinda dumb but makes it easier to read
  @arrow {:->, @bool, @bool}

  @x {:var, :x}
  @y {:var, :y}
  @f {:var, :f}

  setup do
    %{x: :bool, f: @arrow}
  end

  test "lookup", ctx do
    assert BT.synth(ctx, @x) == {:ok, @bool}
    assert BT.synth(ctx, @f) == {:ok, @arrow}
  end

  test "constants" do
    assert BT.synth(%{}, true) == {:ok, @bool}
    assert BT.synth(%{}, false) == {:ok, @bool}
  end

  test "annotations", ctx do
    assert BT.synth(ctx, {:annot, @x, @bool}) == {:ok, @bool}
    assert BT.synth(ctx, {:annot, @f, @arrow}) == {:ok, @arrow}
  end

  test "conditional", ctx do
    assert BT.synth(ctx, {:if, @x, false, true}) == :error
    assert BT.synth(ctx, {:annot, {:if, @x, false, true}, @bool}) == {:ok, @bool}
  end

  test "abstraction" do
    assert BT.check(%{}, {:abs, :y, @y}, @arrow) == {:ok, @arrow}
    assert BT.synth(%{}, {:abs, :y, @y}) == :error
    assert BT.synth(%{}, {:annot, {:abs, :y, @y}, @arrow}) == {:ok, @arrow}
  end

  test "application", ctx do
    assert BT.synth(ctx, {:app, @f, @x}) == {:ok, @bool}
  end
end

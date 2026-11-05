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
    if BT.strict?() do
      assert BT.synth(ctx, {:if, @x, false, true}) == :error
      assert BT.synth(ctx, {:annot, {:if, @x, false, true}, @bool}) == {:ok, @bool}
    else
      assert BT.check(ctx, {:if, @x, false, true}, @bool) == {:ok, @bool}
    end
  end

  test "abstraction" do
    assert BT.check(%{}, {:abs, :y, @y}, @arrow) == {:ok, @arrow}
    assert BT.synth(%{}, {:abs, :y, @y}) == :error
    assert BT.synth(%{}, {:annot, {:abs, :y, @y}, @arrow}) == {:ok, @arrow}
  end

  test "application", ctx do
    assert BT.synth(ctx, {:app, @f, @x}) == {:ok, @bool}
  end

  @b {:var, :b}
  @g {:var, :g}

  test "bigger example from tutorial" do
    # λf. λg. λb. g (f b) : (bool -> bool) -> (bool -> bool) -> bool -> bool

    program = lam(:f, lam(:g, lam(:b, app(@g, app(@f, @b)))))
    type = arrows([@arrow, @arrow, @bool, @bool])

    assert BT.synth(%{}, {:annot, program, type}) == {:ok, type}
  end

  defp lam(x, e), do: {:abs, x, e}
  defp app(e1, e2), do: {:app, e1, e2}

  # arrows are right-associative: arrows([a, b, c]) == a -> (b -> c)
  defp arrows([t]), do: t
  defp arrows([t | ts]), do: {:->, t, arrows(ts)}
end

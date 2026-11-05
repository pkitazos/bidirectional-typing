defmodule BidirectionalTyping do
  @moduledoc """
  Bidirectional Typing for the STLC with Booleans

  Our typing judgement `Γ ⊢ e : t` is split into two judgements

  synthesis: `Γ ⊢ e ==> t`
  checking: `Γ ⊢ e <== t`

  which means we end up with two mutually recursive functions for our typechecking

  synth :: ctx -> e -> result(t)
  check :: ctx -> e -> t -> result(t)

  We're working with a very simple language.
  Our terms ranged over by `e` and our types ranged over by `t` can be seen below.

  Variable names are atoms and the Γ variable binding environment is a map from names (atoms) to types.
  """

  @type name :: atom()
  @type ctx :: %{name() => t()}

  # boolean constants
  @type c :: true | false

  # terms
  @type e ::
          c()
          # x, y, z, ...
          | {:var, name()}
          # e : t
          | {:annot, e(), t()}
          # if e then e else e              <- not particularly readable
          | {:if, e(), e(), e()}
          # e e
          | {:app, e(), e()}
          # λx. t
          | {:abs, name(), e()}

  # types
  @type t ::
          :bool
          # t -> t
          | {:->, t(), t()}

  # $ ctx -> e -> result(t)
  def synth(_, b) when is_boolean(b), do: {:ok, :bool}
  def synth(ctx, {:var, x}), do: lookup(x, ctx)
  def synth(ctx, {:annot, e, t}), do: check(ctx, e, t)

  def synth(ctx, {:app, e1, e2}) do
    with {:ok, {:->, t1, t2}} <- synth(ctx, e1),
         {:ok, ^t1} <- check(ctx, e2, t1) do
      {:ok, t2}
    else
      _ -> :error
    end
  end

  def synth(_, _), do: :error

  # $ ctx -> e -> t -> result(t)
  def check(ctx, {:if, e1, e2, e3}, t) do
    with {:ok, :bool} <- check(ctx, e1, :bool),
         {:ok, ^t} <- check(ctx, e2, t),
         {:ok, ^t} <- check(ctx, e3, t) do
      {:ok, t}
    else
      _ -> :error
    end
  end

  def check(ctx, {:abs, x, e}, {:->, t1, t2} = arrow) do
    case check(extend(ctx, x, t1), e, t2) do
      {:ok, ^t2} -> {:ok, arrow}
      _ -> :error
    end
  end

  def check(_, {:abs, _, _}, _), do: :error

  def check(ctx, e, t) do
    case synth(ctx, e) do
      {:ok, ^t} -> {:ok, t}
      _ -> :error
    end
  end

  # $ name -> ctx -> result(t)
  def lookup(x, ctx), do: Map.fetch(ctx, x)

  # $ ctx -> name -> t -> ctx
  def extend(ctx, x, t), do: Map.put(ctx, x, t)
end

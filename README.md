# Bidirectional Typing

Bidirectional type checking for the simply typed lambda calculus with booleans.

## Syntax

```
c ::= true | false                  boolean constants

e ::= c                             constant
    | x                             variable
    | e : t                         annotation
    | if e then e else e            conditional
    | e e                           application
    | λx. e                         abstraction

t ::= bool                          boolean type
    | t -> t                        function type

Γ ::= ∅ | Γ, x : t                  typing context
```

### Elixir encoding

| Syntax                  | Elixir              |
| ----------------------- | ------------------- |
| `true`, `false`         | `true`, `false`     |
| `x`                     | `{:var, :x}`        |
| `e : t`                 | `{:annot, e, t}`    |
| `if e1 then e2 else e3` | `{:if, e1, e2, e3}` |
| `e1 e2`                 | `{:app, e1, e2}`    |
| `λx. e`                 | `{:abs, :x, e}`     |
| `bool`                  | `:bool`             |
| `t1 -> t2`              | `{:->, t1, t2}`     |
| `Γ`                     | `%{x: t, ...}`      |

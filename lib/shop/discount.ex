defmodule Shop.Discount do
  @moduledoc """
  Defines a discount promo

  A Discount represents promo that can be applied to a `Shop.Checkout` to
  modify the `Checkout`'s price. Each Discount has a `Shop.DiscountKind`
  which defines the rules of how that discount works.
  """

  alias Shop.{Checkout, DiscountKind}

  @enforce_keys [:code, :kind, :parameters]
  defstruct [:code, :inserted_at, :kind, :parameters, :updated_at]

  @typedoc """
  A Discount promotion

  A Discount is basically a combination of a set
  [parameters](`t:Shop.DiscountKind.parameter_spec/0`) and a `Shop.DiscountKind`
  module, in other words, and instance of a `Shop.DiscountKind`.
  """
  @type t :: %__MODULE__{
          code: String.t(),
          inserted_at: DateTime.t() | nil,
          kind: atom(),
          parameters: map(),
          updated_at: DateTime.t() | nil
        }

  @doc """
  Creates a new [`Discount`](`t:Shop.Discount.t/0`)

  Creates a new [`Discount`](`t:Shop.Discount.t/0`) given a `code`, a
  `Shop.DiscountKind` and a set of
  [parameters](`t:Shop.DiscountKind.parameter_spec/0`).

  ## Examples

      iex> Shop.Discount.new("2x1", Shop.Discounts.XForY, %{})
      %Shop.Discount{code: "2x1", kind: Shop.Discounts.XForY, parameters: %{}}
  """
  @spec new(String.t(), atom(), map()) :: t()
  def new(code, kind, parameters),
    do: %__MODULE__{code: code, kind: kind, parameters: parameters}

  @doc """
  Applies a [`Discount`](`t:Shop.Discount.t/0`) to a `Shop.Checkout`

  Given a [`Discount`](`t:Shop.Discount.t/0`) and a `Shop.Checkout` applies that
  `Discount` to the `Checkout`.

  More info at `c:Shop.DiscountKind.apply/2`.

  ## Examples

      iex> coffee = Shop.Product.new("CF1", "Coffee", 2000)
      iex> checkout =
      ...>   "foo"
      ...>   |> Shop.Checkout.new()
      ...>   |> Shop.Checkout.add_product(coffee)
      ...>   |> Shop.Checkout.add_product(coffee)
      iex> discount = Shop.Discount.new("2x1", Shop.Discounts.XForY, %{product: "CF1", x: 2, y: 1})
      iex> Shop.Discount.apply(checkout, discount)
      %Shop.Checkout{
        code: "foo",
        items: [
          %Shop.Product{
            code: "CF1",
            name: "Coffee",
            price: 2000
          },
          %Shop.Product{
            code: "CF1",
            extra: %{discount: "2 for 1", original_price: 2000},
            name: "Coffee",
            price: 0
          }
        ]
      }
  """
  @spec apply(Checkout.t(), t()) :: Checkout.t()
  def apply(checkout, %__MODULE__{kind: kind, parameters: params}) do
    DiscountKind.apply(kind, params, checkout)
  end
end

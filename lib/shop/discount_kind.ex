defmodule Shop.DiscountKind do
  @moduledoc ~S"""
  The discount kind specification

  Each available discount has a kind which is an Elixir module that implements
  the rules of how a discount works. This module defines the common behaviour
  that all of those discount kinds must follow.

  A discount kind module must export:

  * A `c:Shop.DiscountKind.name/1` function that returns the name of the
  discount displayed to the user/client given a set of parameters.
  * An `c:Shop.DiscountKind.apply/2` function that given a set of parameters
  and a `Shop.Checkout` and returns a new `Shop.Checkout` with the discount
  applied.

  As an example, a simple discount kind module could be like this:

  defmodule AllFreeDiscount
    @behaviour Shop.DiscountKind

    @impl true
    def name(_params), do: "All Free"

    @impl true
    def apply(_params, %Shop.Checkout{items: item_list} = checkout) do
      %Shop.Checkout{checkout |
        items: Enum.map(item_list, &(%Shop.Product{&1 | price: 0}))
      }
    end
  end

  Discount kinds are meant to be reused by admins to create new discounts.
  Usually, a discount kind module also accepts parameters in order to customize
  its behaviour. Then, `c:Shop.DiscountKind.spec/0` callback is used to describe
  these parameters and the discount itself. Here is an example:

  defmodule FlatDiscount
    @behaviour Shop.DiscountKind

    @impl true
    def name(%{amount: amount}), do: "Free #{amount} Euros"

    @impl true
    def spec() do
      %{
        description: "Applies a flat amount discount to a product",
        parameters: [
          %{id: :amount, kind: :number, description: "The discount amount"}
        ]
      }
    end

    @impl true
    def apply(%{amount: amount}, %Shop.Checkout{items: item_list} = checkout) do
      %Shop.Checkout{checkout |
        items: Enum.map(item_list, &(%Shop.Product{&1 | price: &1.price - amount}))
      }
    end
  end
  """

  alias Shop.Checkout

  @doc """
  Returns the name of the discount

  Given a set of parameters returns the name of the discount. This name is
  usually shown to clients when a discount is applied.
  """
  @callback name(map()) :: String.t()

  @doc """
  Returns the discount kind specification used to create new discounts

  This function returns the discount specification, which is used by admins to
  create new discounts. The specification contains a `String` description which
  is simply shown to admins and a list of parameter specs. More info on
  `t:Shop.DiscountKind.parameter_spec/0`.
  """
  @callback spec() :: %{description: String.t(), parameters: [parameter_spec()]}

  @doc """
  Applies a discount kind given a list of product and a set of parameters

  Modules implementing this behaviour must apply product modifications here.
  """
  @callback apply(map(), Checkout.t()) :: Checkout.t()

  @optional_callbacks spec: 0

  @typedoc """
  A discount kind parameter specification

  A parameter specification used by the discount kind. For example, a discount
  kind that always discount a flat amount on every product can define a
  parameter spec like this one: `%{id: :amount, kind: :number}`. Then, both
  `c:Shop.DiscountKind.name/1` and `c:Shop.DiscountKind.apply/2` will accept a map
  like `%{amount: 100}` to discount that flat amount to each product.
  """
  @type parameter_spec :: %{
          required(:id) => atom(),
          required(:kind) => :string | :number,
          optional(:description) => String.t()
        }

  @doc """
  Given a `Shop.DiscountKind` module, returns its specification

  Returns the runtime specification of the given `Shop.DiscountKind` module.

  More info at `c:Shop.DiscountKind.spec/0`.
  """
  @spec spec(atom()) :: %{description: String.t(), parameters: [parameter_spec()]}
  def spec(discount_kind), do: Kernel.apply(discount_kind, :spec, [])

  @doc """
  Applies a `Shop.DiscountKind` to a `Shop.Checkout`

  Give a parameter map and a `Shop.Checkout`, applies the `Shop.DiscountKind` to
  that `Shop.Checkout`.

  More info at `c:Shop.DiscountKind.spec/0`.
  """
  @spec apply(atom(), map(), Checkout.t()) :: Checkout.t()
  def apply(discount_kind, parameters, product_list),
    do: Kernel.apply(discount_kind, :apply, [parameters, product_list])
end

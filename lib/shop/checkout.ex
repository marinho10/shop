defmodule Shop.Checkout do
  @moduledoc """
  Defines a shop Checkout

  A Checkout represents a list of the products that clients are about to buy.
  """

  alias Shop.Product

  @enforce_keys [:code, :items]
  defstruct [:code, :inserted_at, :items, :updated_at]

  @typedoc """
  A shop checkout

  Checkouts are lists of `Shop.Checkout.Product`. A code to uniquely identify
  the checkout is required. Optional creation and edition timestamps can also
  be used.
  """

  @type t :: %__MODULE__{
          code: String.t(),
          inserted_at: DateTime.t() | nil,
          items: [Product.t()],
          updated_at: DateTime.t() | nil
        }

  @doc """
  Creates a new `Shop.Checkout`

  Creates a new `Shop.Checkout` given a `code`.

  ## Examples

      iex> Shop.Checkout.new("foo")
      %Shop.Checkout{code: "foo", items: []}
  """
  @spec new(String.t() | nil) :: t
  def new(code), do: %__MODULE__{code: code, items: []}

  @doc """
  Adds a `Shop.Product` to a `Shop.Checkout`

  Adds a `Shop.Product` to the end of the product list of a `Shop.Checkout`.

  ## Examples

      iex> checkout = Shop.Checkout.new("foo")
      iex> first_product = Shop.Product.new("GR1", "Green tea", 311)
      iex> second_product = Shop.Product.new("CF1", "Coffee", 1123)
      iex> checkout
      ...> |> Shop.Checkout.add_product(second_product)
      ...> |> Shop.Checkout.add_product(first_product)
      %Shop.Checkout{code: "foo", items: [
        %Shop.Product{code: "GR1", name: "Green tea", price: 311},
        %Shop.Product{code: "CF1", name: "Coffee", price: 1123}
      ]}
  """
  @spec add_product(t(), Product.t()) :: t
  def add_product(%__MODULE__{items: items} = checkout, product) do
    %__MODULE__{checkout | items: [product | items]}
  end

  @doc """
  Returns the price of a `Shop.Checkout`

  Computes the total price of a `Shop.Checkout` by adding all items.

  ## Examples

      iex> checkout = Shop.Checkout.new("foo")
      iex> first_product = Shop.Product.new("GR1", "Green tea", 311)
      iex> second_product = Shop.Product.new("CF1", "Coffee", 1123)
      iex> checkout
      ...> |> Shop.Checkout.add_product(second_product)
      ...> |> Shop.Checkout.add_product(first_product)
      ...> |> Shop.Checkout.price()
      1434
  """
  @spec price(t) :: non_neg_integer()
  def price(%__MODULE__{items: item_list}) do
    Enum.reduce(item_list, 0, fn %Product{price: item_price}, acc ->
      item_price + acc
    end)
  end
end

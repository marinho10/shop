defmodule Shop.Product do
  @moduledoc """
  Defines a shop Product

  Clients are able to buy units of these products.
  """

  @enforce_keys [:code, :name, :price]
  defstruct [:code, :extra, :inserted_at, :name, :price, :updated_at]

  @typedoc """
  A shop product

  Every product must define the following fields:

    * A unique `code` which is used as unique identifier.
    * A descriptive `name`.
    * A `price` in pound cents.

  Optionally, an `extra` field containing a map can be added to a product. This
  field it is used for additional information about that product, for example,
  if a discount is being applied to it. Optional creation and edition timestamps
  can also be used.
  """
  @type t :: %__MODULE__{
          code: String.t(),
          extra: map | nil,
          inserted_at: DateTime.t() | nil,
          name: String.t(),
          price: non_neg_integer,
          updated_at: DateTime.t() | nil
        }

  @doc """
  Creates a new Product

  Creates a new Product given a `code`, `name` and `price`.

  ## Examples

      iex> Shop.Product.new("foo", "Foo", 9001)
      %Shop.Product{code: "foo", name: "Foo", price: 9001}
  """
  @spec new(String.t(), String.t(), non_neg_integer()) :: t()
  def new(code, name, price),
    do: %__MODULE__{code: code, name: name, price: price}
end

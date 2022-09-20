defmodule Shop.Discounts.XForY do
  @moduledoc """
  Discounts of type 2x1, 3x2, etc.

  A Discount for X-for-Y promotions, like 2-for-1, i.e., buy two products of the
  same product and get on free.

  See `Shop.DiscountKind` for more information about how to use discounts.

  The parameters needed to run this discount are:

    * `product` `String`: The product code where the discount applies.
    * `x` `Number`: The number of products that the client have to buy in order
      to apply the discount.
    * `y` `Number`: The number of products given free.
  """

  @behaviour Shop.DiscountKind

  alias Shop.{Checkout, Product}

  @impl true
  def spec() do
    %{
      description: "Buy X of the same product, get Y free",
      parameters: [
        %{
          id: :product,
          kind: :string,
          description: "The product code where the discount applies"
        },
        %{
          id: :x,
          kind: :number,
          description:
            "The number of products that the client have to buy in order to apply the discount"
        },
        %{id: :y, kind: :number, description: "The number of products given free"}
      ]
    }
  end

  @impl true
  def name(%{x: x, y: y}), do: "#{x} for #{y}"

  @impl true
  def apply(%{x: x, y: x}, checkout), do: checkout

  @impl true
  def apply(%{x: x, y: y}, checkout) when x <= 0 or y <= 0, do: checkout

  @impl true
  def apply(%{x: x, y: y}, checkout) when x < y, do: checkout

  @impl true
  def apply(%{x: x, y: y, product: product} = params, %Checkout{items: item_list} = checkout) do
    product_count = Enum.count(item_list, &Kernel.==(product, &1.code))

    updated_item_list =
      item_list
      |> Enum.reduce({0, product_count, []}, fn
        # First product on discount, client always pays for it
        %Product{code: ^product} = item, {0, rem, acc} when rem >= x ->
          {x - 1, rem - x, [item | acc]}

        # Product on discount, but not enough to apply the discount
        %Product{code: ^product} = item, {curr, rem, acc} when curr > 0 and x - curr < y ->
          {curr - 1, rem, [item | acc]}

        # Product on discount and enough to apply the discount
        %Product{code: ^product} = item, {curr, rem, acc} when curr > 0 and x - curr >= y ->
          {curr - 1, rem, [apply_discount(params, item) | acc]}

        # Remaining products
        item, {curr, rem, acc} ->
          {curr, rem, [item | acc]}
      end)
      |> elem(2)
      |> Enum.reverse()

    %Checkout{checkout | items: updated_item_list}
  end

  defp apply_discount(params, product) do
    extra = product.extra || %{}

    %Product{
      product
      | price: 0,
        extra: Map.merge(extra, %{discount: name(params), original_price: product.price})
    }
  end
end

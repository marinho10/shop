defmodule Shop.DiscountTest do
  use Shop.Case, async: true

  doctest Shop.Discount

  alias Shop.{Checkout, Discount, Discounts.Bulk, Discounts.XForY, Product}

  describe "Task scenario" do
    setup do
      coffee = Product.new("CF1", "Coffee", 1123)
      strawberries = Product.new("SR1", "Strawberries", 500)
      tee = Product.new("GR1", "Green tea", 311)

      discounts = [
        Discount.new("CEO Discount", XForY, %{x: 2, y: 1, product: tee.code}),
        Discount.new("COO Discount", Bulk, %{count: 3, price: 450, product: strawberries.code}),
        Discount.new("CTO Discount", Bulk, %{count: 3, price: 2 / 3, product: coffee.code})
      ]

      {:ok, coffee: coffee, strawberries: strawberries, tee: tee, discounts: discounts}
    end

    test "one", %{coffee: coffee, strawberries: strawberries, tee: tee, discounts: discounts} do
      price =
        "checkout"
        |> Checkout.new()
        |> Checkout.add_product(tee)
        |> Checkout.add_product(strawberries)
        |> Checkout.add_product(tee)
        |> Checkout.add_product(tee)
        |> Checkout.add_product(coffee)
        |> apply_discounts(discounts)
        |> Checkout.price()

      assert price == 2245
    end

    test "two", %{tee: tee, discounts: discounts} do
      price =
        "checkout"
        |> Checkout.new()
        |> Checkout.add_product(tee)
        |> Checkout.add_product(tee)
        |> apply_discounts(discounts)
        |> Checkout.price()

      assert price == 311
    end

    test "three", %{strawberries: strawberries, tee: tee, discounts: discounts} do
      price =
        "checkout"
        |> Checkout.new()
        |> Checkout.add_product(strawberries)
        |> Checkout.add_product(strawberries)
        |> Checkout.add_product(tee)
        |> Checkout.add_product(strawberries)
        |> apply_discounts(discounts)
        |> Checkout.price()

      assert price == 1661
    end

    test "four", %{coffee: coffee, strawberries: strawberries, tee: tee, discounts: discounts} do
      price =
        "checkout"
        |> Checkout.new()
        |> Checkout.add_product(tee)
        |> Checkout.add_product(coffee)
        |> Checkout.add_product(strawberries)
        |> Checkout.add_product(coffee)
        |> Checkout.add_product(coffee)
        |> apply_discounts(discounts)
        |> Checkout.price()

      assert price == 3057
    end
  end

  defp apply_discounts(checkout, discounts),
    do: Enum.reduce(discounts, checkout, &Discount.apply(&2, &1))
end

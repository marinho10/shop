defmodule Shop.Discounts.XForYTest do
  use Shop.Case, async: true

  alias Shop.{Checkout, Discounts.XForY, Product}

  property "does nothing when applied to a non-existing product" do
    forall checkout <- checkout(item_codes: ~w(bar qux)) do
      checkout_after_discount = XForY.apply(%{x: 2, y: 1, product: "foo"}, checkout)
      assert checkout_after_discount == checkout
    end
  end

  property "does nothing when X == Y" do
    forall [checkout <- checkout(item_codes: ~w(foo bar qux)), x <- pos_integer()] do
      checkout_after_discount = XForY.apply(%{x: x, y: x, product: "foo"}, checkout)
      assert checkout_after_discount == checkout
    end
  end

  property "does nothing when X or Y are less than or equal zero" do
    forall [
      checkout <- checkout(item_codes: ~w(foo bar qux)),
      x <- non_neg_integer(),
      y <- non_neg_integer()
    ] do
      checkout_after_discount = XForY.apply(%{x: -x, y: -y, product: "foo"}, checkout)
      checkout_after_discount_x = XForY.apply(%{x: -x, y: 1, product: "foo"}, checkout)
      checkout_after_discount_y = XForY.apply(%{x: 1, y: -y, product: "foo"}, checkout)

      assert checkout == checkout_after_discount
      assert checkout == checkout_after_discount_x
      assert checkout == checkout_after_discount_y
    end
  end

  property "does nothing when X < Y, it will be not a discount" do
    forall [
      checkout <- checkout(item_codes: ~w(foo bar qux)),
      x <- pos_integer(),
      y <- pos_integer()
    ] do
      implies x < y do
        checkout_after_discount = XForY.apply(%{x: x, y: y, product: "foo"}, checkout)
        assert checkout == checkout_after_discount
      end
    end
  end

  property "price is always equal or lower than without discount (upper bound)" do
    forall checkout <- checkout(non_empty: true, free_items: false, item_codes: ~w(foo bar qux)) do
      checkout_after_discount = XForY.apply(%{x: 2, y: 1, product: "foo"}, checkout)
      assert Checkout.price(checkout_after_discount) <= Checkout.price(checkout)
    end
  end

  property "price is always equal or greater than all-in discount ratio (lower bound)" do
    forall [
      checkout <- checkout(non_empty: true, free_items: false, item_codes: ~w(foo bar qux)),
      x <- pos_integer(),
      y <- pos_integer()
    ] do
      implies x < y do
        checkout_after_discount = XForY.apply(%{x: x, y: y, product: "foo"}, checkout)
        assert Checkout.price(checkout_after_discount) >= Checkout.price(checkout) * x / y
      end
    end
  end

  setup do
    tee = Product.new("GR1", "Green tea", 500)
    coffee = Product.new("CF1", "Coffee", 2000)

    {:ok, tee: tee, coffee: coffee}
  end

  test "5x3 in a checkout with 6 products on discount", %{tee: tee, coffee: coffee} do
    checkout =
      "checkout"
      |> Checkout.new()
      |> Checkout.add_product(tee)
      |> Checkout.add_product(coffee)
      |> Checkout.add_product(tee)
      |> Checkout.add_product(coffee)
      |> Checkout.add_product(tee)
      |> Checkout.add_product(tee)
      |> Checkout.add_product(tee)
      |> Checkout.add_product(tee)
      |> Checkout.add_product(coffee)

    checkout_after_discount = XForY.apply(%{x: 5, y: 3, product: tee.code}, checkout)
    assert Checkout.price(checkout_after_discount) == 8000
  end

  test "discount attach extra information", %{coffee: coffee} do
    checkout =
      "checkout"
      |> Checkout.new()
      |> Checkout.add_product(coffee)
      |> Checkout.add_product(coffee)

    discount = %{x: 2, y: 1, product: coffee.code}

    product_discount =
      discount
      |> XForY.apply(checkout)
      |> Map.get(:items)
      |> Enum.at(1)
      |> Map.get(:extra)
      |> Map.get(:discount)

    assert product_discount == XForY.name(discount)
  end
end

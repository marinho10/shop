defmodule Shop.Case do
  use ExUnit.CaseTemplate
  use PropCheck

  using do
    quote do
      use PropCheck
      import Shop.Case
    end
  end

  def checkout(options \\ []) do
    {options, customs} = Keyword.split(options, [:free_items, :non_empty, :item_codes])

    let [
      code <- noshrink(alphanum_string()),
      items <- items(options)
    ] do
      customs_map = Enum.into(customs, %{})
      checkout = %Shop.Checkout{code: code, items: items}

      checkout
      |> Map.merge(customs_map)
      |> apply_item_codes(Keyword.get(options, :item_codes, []))
      |> apply_free_items(Keyword.get(options, :free_items, true))
    end
  end

  def product(customs \\ []) do
    let [
      code <- noshrink(alphanum_string()),
      name <- noshrink(alphanum_string()),
      price <- non_neg_integer()
    ] do
      customs_map = Enum.into(customs, %{})
      product = %Shop.Product{code: code, name: name, price: price}

      Map.merge(product, customs_map)
    end
  end

  def alphanum_string() do
    let charlist <- non_empty(list(union(alphabet()))) do
      to_string(charlist)
    end
  end

  defp apply_item_codes(checkout, []), do: checkout

  defp apply_item_codes(checkout, codes) do
    items_with_codes =
      checkout.items
      |> Enum.with_index()
      |> Enum.map(fn {e, i} -> %{e | code: Enum.at(codes, rem(i, 3))} end)

    %{checkout | items: items_with_codes}
  end

  defp apply_free_items(checkout, true), do: checkout

  defp apply_free_items(checkout, false) do
    items = Enum.map(checkout.items, &%{&1 | price: &1.price + 1})
    %{checkout | items: items}
  end

  defp items(options) do
    if Keyword.get(options, :non_empty, false) do
      non_empty(list(product()))
    else
      list(product())
    end
  end

  defp alphabet() do
    [?0..?1, ?A..?Z, ?a..?z]
    |> Enum.map(&Enum.to_list/1)
    |> Enum.concat()
  end
end

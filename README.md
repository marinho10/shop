# Shop Project

[![Elixir CI Status](https://github.com/alvivi/shop/workflows/Elixir%20CI/badge.svg)](https://github.com/alvivi/shop/actions)
[![codecov](https://codecov.io/gh/alvivi/shop/branch/master/graph/badge.svg?token=CPt0HwxHp9)](https://codecov.io/gh/alvivi/shop)

This project contains an [Elixir](https://elixir-lang.org/) library that can
be used as a model for managing shop checkouts.

## Building and Running the Project

In order to build and run this project, you need a working *Elixir* environment.
You can follow the [Installing Elixir](https://elixir-lang.org/install.html)
guide to get *Elixir* running in your system.

The minimum version required by this project is defined in the
[mix.exs](mix.exs) file.

### Installing Elixir with ASDF

A common problem in every development environment is having multiple projects
requiring different versions of the same tools.
[ASDF](https://asdf-vm.com/) is a utility that manages multiple
language runtime versions on a per-project basis.

This project has a [.tool-versions](.tool-versions) file that specifies the
elixir version required by the project. *ASDF* uses this file to set the
specified elixir runtime. After getting
[ASDF installed](https://asdf-vm.com/#/core-manage-asdf-vm), you can run
`asdf install` in the root folder of this project to get a working elixir
environment.

### Using Elixir through Docker

Another available option is to avoid messing with your local environment
and use a [Docker](https://www.docker.com/) container.

The following command creates an interactive terminal session ready for
building this project:

```bash
docker run -ti \
  --entrypoint /bin/bash \
  --mount type=bind,source="$(pwd)",target=/code \
  -w /code \
  elixir:$(cat .tool-versions | grep elixir | grep -o "[0-9]\.[0-9]")
```

### Running the Project

When you have the required elixir environment working, running this project is
pretty straightforward. We only have to install the dependencies and we are
ready for an interactive session:

```bash
$ mix deps.get
...
$ iex -S mix
iex(1)>
```

Then, we can start playing with the library.

```elixir
iex(1)> tee = Shop.Product.new("GR1", "Green tea", 311)
%Shop.Product{...}
iex(2)> checkout = Shop.Checkout.new("checkout")
%Shop.Checkout{...}
iex(3)> checkout = Shop.Checkout.add_product(checkout, tee)
%Shop.Checkout{items: [%Shop.Product{...}], ...}
iex(4)> checkout = Shop.Checkout.add_product(checkout, tee)
%Shop.Checkout{items: [%Shop.Product{...}, %Shop.Product{...}], ...}
iex(5)> discount = Shop.Discount.new("CEO Discount", Shop.Discounts.XForY, %{x: 2, y: 1, product: tee.code})
%Shop.Discount{...}
iex(6)> checkout = Shop.Discount.apply(checkout, discount)
%Shop.Checkout{...}
iex(6)> Shop.Checkout.price(checkout)
311
```

## Testing

You can run `mix test` on this project to run all the tests available.

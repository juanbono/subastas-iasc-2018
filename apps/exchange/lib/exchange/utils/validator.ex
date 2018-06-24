defmodule Exchange.Validator do
  def buyers() do
    quote do
      import Exchange.Validator.Buyer
    end
  end

  def bids() do
    quote do
      import Exchange.Validator.Bid
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

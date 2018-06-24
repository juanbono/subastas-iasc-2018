defmodule Exchange.Validator.Buyer do
  import Exchange.Validator.Utils

  @doc """
  Un comprador válido debe proporcionar:
    * Un `nombre` lógico.
    * Su dirección `IP`.
    * Una lista con los `tags` de su interés.
  """
  def valid?(buyer) do
    [&has_name/1, &has_ip/1, &has_tags/1]
    |> all?(buyer)
  end
end

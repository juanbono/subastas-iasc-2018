defmodule Exchange.Validator.Bid do
  import Exchange.Validator.Utils

  @doc """
  Una apuesta válida debe tener:
    * Una lista de `tags`.
    * Su `precio` base (que puede ser 0).
    * La `duración` máxima de la subasta (expresada en ms).
    * Un `JSON` con la información del articulo.
  """
  def valid?(bid) do
    [&has_tags/1, &has_price/1, &has_duration/1, &has_json/1]
    |> all?(bid)
  end

  def valid?(id, bid) do
    valid_id = has_valid_id(id)

    valid_conn =
      [&has_name/1, &has_price/1]
      |> all?(bid)

    valid_id && valid_conn
  end
end

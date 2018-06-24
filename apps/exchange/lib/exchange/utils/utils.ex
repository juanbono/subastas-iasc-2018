defmodule Exchange.Validator.Utils do
  def all?(predicates, data) do
    if Enum.all?(predicates, fn pred -> pred.(data) end) do
      {:ok, data}
    else
      # aca se podrian manejar casos de error mas especificos
      {:error, :invalid_json}
    end
  end

  def has_valid_id(id), do: Exchange.Bids.exists?(id)
  def has_name(data), do: Map.has_key?(data, "name")
  def has_ip(data), do: Map.has_key?(data, "ip")
  def has_tags(data), do: Map.has_key?(data, "tags")
  def has_price(data), do: Map.has_key?(data, "price")
  def has_duration(data), do: Map.has_key?(data, "duration")
  def has_json(data), do: Map.has_key?(data, "json")
end

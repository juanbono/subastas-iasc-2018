defmodule Exchange.Utils.Time do
  @moduledoc """
  Modulo con funciones utiles para obtener el tiempo en
  formato UTC dentro de una cantidad dada de segundos/minutos/horas.
  """
  use Timex

  def sec(amount) do
    DateTime.utc_now()
    |> Timex.shift(seconds: amount)
    |> DateTime.to_unix()
  end

  def min(amount) do
    DateTime.utc_now()
    |> Timex.shift(minutes: amount)
    |> DateTime.to_unix()
  end

  def hour(amount) do
    DateTime.utc_now()
    |> Timex.shift(hours: amount)
    |> DateTime.to_unix()
  end
end

defmodule Client.Utils do
  @moduledoc """
  Modulo con funciones utiles para obtener el tiempo en
  formato UNIX dentro de una cantidad dada de segundos/minutos/horas.
  Este modulo sirve mas que nada para facilitar la realizacion de tests manuales.
  """
  use Timex

  @doc """
  Devuelve el tiempo (en formato UNIX) dentro de `n` segundos.
  """
  def sec(amount) do
    DateTime.utc_now()
    |> Timex.shift(seconds: amount)
    |> DateTime.to_unix()
  end

  @doc """
  Devuelve el tiempo (en formato UNIX) dentro de `n` minutos.
  """
  def min(amount) do
    DateTime.utc_now()
    |> Timex.shift(minutes: amount)
    |> DateTime.to_unix()
  end

  @doc """
  Devuelve el tiempo (en formato UNIX) dentro de `n` horas.
  """
  def hour(amount) do
    DateTime.utc_now()
    |> Timex.shift(hours: amount)
    |> DateTime.to_unix()
  end
end

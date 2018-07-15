defmodule Exchange.Buyers.Interfaces.Local do
  alias Exchange.Buyers

  def notify_buyers(:new, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_new(pid, bid) end)
  end

  def notify_buyers(:update, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_update(pid, bid) end)
  end

  def notify_buyers(:cancelled, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_cancelled(pid, bid) end)
  end

  def notify_buyers(:finalized, bid) do
    Buyers.Supervisor.current_buyers()
    |> Enum.each(fn pid -> Buyers.Worker.notify_finalized(pid, bid) end)
  end
end

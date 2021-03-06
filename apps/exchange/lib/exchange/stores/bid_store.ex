defmodule Mnesiam.Support.BidStore do
  @moduledoc """
  Bid Store implementation
  """

  alias :mnesia, as: Mnesia

  @table :bid_table

  @doc """
  Mnesiam will call this method to init table
  """
  def init_store do
    Mnesia.create_table(
      @table,
      ram_copies: [Node.self()],
      type: :set,
      attributes: [:bid_id, :price, :close_at, :json, :tags, :winner, :state]
    )
  end

  @doc """
  Mnesiam will call this method to copy table
  """
  def copy_store do
    Mnesia.add_table_copy(@table, Node.self(), :ram_copies)
  end

  def store(bid) do
    Mnesia.transaction(fn ->
      Mnesia.write({
        :bid_table,
        bid.bid_id,
        bid.price,
        bid.close_at,
        bid.json,
        bid.tags,
        bid.winner,
        bid.state
      })
    end)

    bid
  end
end

require_relative '../lib/sales_engine'
require_relative '../lib/invoice_item_repository'
require 'bigdecimal/util'
require 'time'

class InvoiceItem
  attr_reader :created_at
  attr_accessor :id,
                :item_id,
                :invoice_id,
                :quantity,
                :unit_price,
                :updated_at

  def initialize(info_hash)
    @id = info_hash[:id].to_i
    @item_id = info_hash[:item_id].to_i
    @invoice_id = info_hash[:invoice_id].to_i
    @quantity = info_hash[:quantity].to_i
    @unit_price = info_hash[:unit_price].to_d / 100
    @created_at = time_check(info_hash[:created_at])
    @updated_at = time_check(info_hash[:updated_at])
  end

  def time_check(time)
    if time.class == Time
      time
    else
      Time.parse(time)
    end
  end

  def unit_price_to_dollars
    (@unit_price.to_f).round(4)
  end
end

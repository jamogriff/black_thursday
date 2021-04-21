require_relative '../lib/sales_engine'
require_relative '../lib/item_repository'
require 'bigdecimal/util'
require 'time'

class Item
attr_reader  :created_at,
              :merchant_id
attr_accessor :id,
              :updated_at,
              :name,
              :description,
              :unit_price

  def initialize(info_hash)
    @id = info_hash[:id].to_i
    @name = info_hash[:name]
    @description = info_hash[:description]
    @unit_price = info_hash[:unit_price].to_d / 100
    @created_at = time_check(info_hash[:created_at])
    @updated_at = time_check(info_hash[:updated_at])
    @merchant_id = info_hash[:merchant_id].to_i
  end

  def unit_price_to_dollars
    (@unit_price.to_f).round(4)
  end

  def time_check(time)
    if time.class == Time
      time
    else
      Time.parse(time)
    end
  end
end

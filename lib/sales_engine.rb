require 'CSV'
require_relative '../lib/merchant_repository'
require_relative '../lib/item_repository'
require_relative '../lib/invoice_repository'
require_relative '../lib/invoice_item_repository'
require_relative '../lib/customer_repository'
require_relative '../lib/transaction_repository'
require_relative '../lib/sales_analyst'

class SalesEngine
  attr_reader :merchants,
              :items,
              :invoices,
              :invoice_items,
              :customers,
              :transactions,
              :analyst

  def initialize(csv_data)
    @merchants ||= MerchantRepository.new(csv_data[:merchants])
    @items ||= ItemRepository.new(csv_data[:items])
    @invoices ||= InvoiceRepository.new(csv_data[:invoices])
    @invoice_items ||= InvoiceItemRepository.new(csv_data[:invoice_items])
    @customers ||= CustomerRepository.new(csv_data[:customers])
    @transactions ||= TransactionRepository.new(csv_data[:transactions])
    @analyst ||= SalesAnalyst.new(self)
  end

  def self.from_csv(csv_data)
     SalesEngine.new(csv_data)
  end

  def get_all_merchants
    @merchants.array_of_objects
  end

  def get_all_items
    @items.array_of_objects
  end

  def get_all_invoices
    @invoices.array_of_objects
  end

  def get_all_invoice_items
    @invoice_items.array_of_objects
  end

  def get_all_transactions
    @transactions.array_of_objects
  end

  def items_per_merchant
    @merchants.array_of_objects.map do |merchant|
      find_all_items_by_merchant_id(merchant.id).length
    end
  end

  def find_all_items_by_merchant_id(merchant_id)
    @items.array_of_objects.find_all do |item_object|
      item_object.merchant_id == merchant_id
    end
  end

  def find_transactions_by_invoice_id(invoice_id)
    @transactions.array_of_objects.find_all do |transaction|
      transaction.invoice_id == invoice_id
    end
  end

  def price_per_item
    items.array_of_objects.map do |item_object|
      item_object.unit_price
    end
  end

  def invoices_per_day
    days = @invoices.array_of_objects.map do |invoice_object|
      invoice_object.created_at.strftime('%A')
    end
    sorted_days = days.group_by do |day|
      day
    end
    sorted_days.transform_values do |value|
      value.length
    end
  end

  def find_all_invoices_by_merchant_id(merchant_id)
    @invoices.array_of_objects.find_all do |invoice|
      invoice.merchant_id == merchant_id
    end
  end

  def invoices_per_merchant
    @merchants.array_of_objects.map do |merchant|
      find_all_invoices_by_merchant_id(merchant.id).length
    end
  end

end

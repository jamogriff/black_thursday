require_relative 'compute'
require 'date'

class SalesAnalyst

  attr_reader :engine,
              :merchants,
              :items,
              :invoices,
              :transactions,
              :invoice_items

  def initialize(engine)
    @engine = engine
    @merchants ||= engine.get_all_merchants
    @items ||= engine.get_all_items
    @invoices ||= engine.get_all_invoices
    @transactions ||= engine.get_all_transactions
    @invoice_items ||= engine.get_all_invoice_items
  end

  def get_merchant_ids(merchants)
    merchants.map do |merchant|
      merchant.id
    end
  end

  def average_items_per_merchant
    Compute.mean(engine.items_per_merchant.sum, engine.items_per_merchant.length)
  end

  def average_items_per_merchant_standard_deviation
    Compute.standard_deviation(engine.items_per_merchant)
  end

  def merchants_with_high_item_count
    mean = average_items_per_merchant
    greater_than_1sd = mean + average_items_per_merchant_standard_deviation
    merchants.find_all do |merchant|
      engine.find_all_items_by_merchant_id(merchant.id).length > greater_than_1sd
    end
  end

  def average_item_price_for_merchant(merchant_id)
    merchant_items = @engine.find_all_items_by_merchant_id(merchant_id)
    sum_of_prices = merchant_items.sum do |item_object|
      item_object.unit_price
    end
    if merchant_items.length != 0
      Compute.mean(sum_of_prices, merchant_items.length)
    else
      0
    end
  end

  def average_average_price_per_merchant
    items_sum = merchants.sum do |merchant|
      average_item_price_for_merchant(merchant.id)
    end
    Compute.mean(items_sum, merchants.length)
  end

  def total_item_price
    items.sum do |item_object|
      item_object.unit_price
    end
  end

  # def price_per_item
  #   test = items.map do |item_object|
  #     item_object.unit_price
  #   end
  # end

  def average_price_per_item_standard_deviation
    Compute.standard_deviation(engine.price_per_item)
  end

  def golden_items
    mean = Compute.mean(total_item_price, items.length)
    two_sd = average_price_per_item_standard_deviation * 2
    greater_than_2sd = mean + two_sd
    items.find_all do |item_object|
      item_object.unit_price >= greater_than_2sd
    end
  end

  def average_invoices_per_merchant
    Compute.mean(invoices_per_merchant.sum, invoices_per_merchant.length)
  end

  def find_all_invoices_by_merchant_id(merchant_id)
    invoices.find_all do |invoice|
      invoice.merchant_id == merchant_id
    end
  end

  def invoices_per_merchant
    merchants.map do |merchant|
      find_all_invoices_by_merchant_id(merchant.id).length
    end
  end

  def average_invoices_per_merchant_standard_deviation
    Compute.standard_deviation(invoices_per_merchant)
  end

  def average_invoices_per_day_standard_deviation
    average_invoices_per_day = Compute.mean(invoices.length, 7)
    adder_counter = engine.invoices_per_day.values.sum do |number_of_invoices|
      (number_of_invoices - average_invoices_per_day)**2
    end
    Math.sqrt(adder_counter.to_f / 6).round(2)
  end

  def top_days_by_invoice_count
    days_hash = engine.invoices_per_day.select do |key, value|
      value > average_invoices_per_day_standard_deviation + (invoices.length/7)
    end
    days_hash.keys
  end

  def invoice_status(status_symbol)
    sorted_invoices = []
     @invoices.each do |invoice|
       if invoice.status == status_symbol
      sorted_invoices.push(invoice)
      end
    end
    (sorted_invoices.length/@invoices.length.to_f*100).round(2)
  end

  def invoice_total(invoice_id)
    all_invoice_items = invoice_items.find_all do |invoice_item|
      invoice_item.invoice_id == invoice_id &&
      invoice_paid_in_full?(invoice_item.invoice_id)
    end
    all_invoice_items.sum do |invoice_item|
      (invoice_item.quantity * invoice_item.unit_price)
    end
  end

  def invoice_paid_in_full?(invoice_id)
    all_transactions = transactions.find_all do |transaction|
      transaction.invoice_id == invoice_id
    end
    if all_transactions.length != 0
      all_transactions.any? do |transaction|
        transaction.result == :success
      end
    else
      false
    end
  end

  def top_merchants_by_invoice_count
    mean = average_invoices_per_merchant
    upper_bound = mean + average_invoices_per_merchant_standard_deviation * 2
    merchants.find_all do |merchant|
      find_all_invoices_by_merchant_id(merchant.id).length > upper_bound
    end
  end

  def bottom_merchants_by_invoice_count
    mean = average_invoices_per_merchant
    lower_bound = mean - average_invoices_per_merchant_standard_deviation * 2
    merchants.find_all do |merchant|
      find_all_invoices_by_merchant_id(merchant.id).length < lower_bound
    end
  end

  def revenue_by_merchant(merchant_id)
    merchant_invoices = find_all_invoices_by_merchant_id(merchant_id)
    merchant_invoices.sum do |invoice|
      invoice_total(invoice.id)
    end
  end

  def top_revenue_earners(count=20)
    merchants_by_revenue = @merchants.reduce({}) do |merchants_by_revenue, merchant|
      merchants_by_revenue[merchant] = revenue_by_merchant(merchant.id)
      merchants_by_revenue
    end

    merchants_by_revenue = merchants_by_revenue.sort_by do |merchant, revenue|
      revenue
    end.reverse!

    top_merchants_with_totals = merchants_by_revenue.first(count)

    top_merchants = top_merchants_with_totals.flat_map do |merchant_with_total|
      merchant_with_total[0]
    end
  end

  def total_revenue_by_date(date)
    invoice_id_matching_date = 0
    @invoices.each do |invoice|
      if invoice.created_at == date
        invoice_id_matching_date += invoice.id
      end
      invoice_id_matching_date
      invoices_total_by_date = invoice_total(invoice_id_matching_date)
      return invoices_total_by_date
    end
  end

  def find_transactions_by_invoice_id(invoice_id)
    transactions.find_all do |transaction|
      transaction.invoice_id == invoice_id
    end
  end

  def check_pending_invoice(invoice)
    transactions = find_transactions_by_invoice_id(invoice.id)
    failed_transactions = transactions.none? do |transaction|
      transaction.result == :success
    end
    failed_transactions
  end

  def merchants_with_pending_invoices
    all_merchants = merchants.find_all do |merchant|
      merchant_invoices = find_all_invoices_by_merchant_id(merchant.id)
      merchant_invoices.any? do |invoice|
        check_pending_invoice(invoice)
      end
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchants_with_only_one_item.find_all do |merchant|
      merchant.created_at.strftime('%B') == month
    end
  end

  def merchants_with_only_one_item
    @merchants.find_all do |merchant|
      @engine.find_all_items_by_merchant_id(merchant.id).length == 1
    end
  end
end

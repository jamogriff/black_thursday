require_relative '../lib/transaction'
require_relative '../lib/repository'

class TransactionRepository < Repository

  def initialize(path)
    super(path, Transaction)
  end

  def update(id, attributes)
    target = find_by_id(id)
    if target != nil
      target.credit_card_number = attributes[:credit_card_number] if attributes[:credit_card_number] != nil
      target.credit_card_expiration_date = attributes[:credit_card_expiration_date] if attributes[:credit_card_expiration_date] != nil
      target.result = attributes[:result] if attributes[:result] != nil
      target.updated_at = Time.now
    end
  end

  def find_all_by_invoice_id(invoice_id)
    @array_of_objects.find_all do |transaction|
      transaction.invoice_id == invoice_id
    end
  end

  def find_all_by_credit_card_number(credit_card_number)
    @array_of_objects.find_all do |transaction|
      transaction.credit_card_number == credit_card_number
    end
  end

  def find_all_by_result(result)
    @array_of_objects.find_all do |transaction|
      transaction.result == result
    end
  end
end

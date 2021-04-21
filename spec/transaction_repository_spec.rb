require_relative '../lib/sales_engine'
require_relative '../lib/transaction_repository'

RSpec.describe TransactionRepository do
  sales_engine = SalesEngine.from_csv({
                                        :items     => "./data/items.csv",
                                        :merchants => "./data/merchants.csv",
                                        :invoices => "./data/invoices.csv",
                                        :customers => "./data/customers.csv",
                                        :invoice_items => "./data/invoice_items.csv",
                                        :transactions => "./data/transactions.csv"
                                        })

    transaction_repo = sales_engine.transactions

  describe 'initialization' do

    it 'exists' do
      expect(transaction_repo).to be_instance_of(TransactionRepository)
    end

    it 'can create transaction objects' do
      expect(transaction_repo.array_of_objects[0]).to be_instance_of(Transaction)
    end
  end

  describe 'parent class methods' do

    it '#all returns array of all transactions' do
      expect(transaction_repo.all.length).to eq(4985)
    end

    it '#find_by_id returns an instance by matching id' do
      id = 50

      expect(transaction_repo.find_by_id(id).id).to eq(id)
      expect(transaction_repo.find_by_id(id).result).to eq(:success)
    end

    it '#create creates new instance with id one higher' do
      attributes = {
        :invoice_id => 8,
        :credit_card_number => "4242424242424242",
        :credit_card_expiration_date => "0220",
        :result => "success",
        :created_at => Time.now,
        :updated_at => Time.now
      }
      transaction_repo.create(attributes, Transaction)

      expect(transaction_repo.all.length).to eq(4986)
      expect(transaction_repo.all.last).to be_an_instance_of(Transaction)
      expect(transaction_repo.all.last.credit_card_expiration_date).to eq("0220")
      expect(transaction_repo.all.last.id).to eq(4986)
    end

    it '#delete can delete transaction' do
      transaction_repo.delete(4986)
      expected = transaction_repo.find_by_id(4986)
      expect(expected).to eq(nil)
    end
  end

  describe 'instance methods' do

    it '#find_all_by_invoice_id returns array of transactions with matching invoice id' do
      test_id = 2179
      empty_id = 1000

      expect(transaction_repo.find_all_by_invoice_id(test_id).length).to eq(2)
      expect(transaction_repo.find_all_by_invoice_id(empty_id)).to eq([])
    end

    it '#find_all_by_credit_card_number returns array of transactions with matching cc no' do
      test_cc = "4184649339029337"
      empty_cc = "000000000000"

      expect(transaction_repo.find_all_by_credit_card_number(test_cc).length).to eq(1)
      expect(transaction_repo.find_all_by_credit_card_number(empty_cc)).to eq([])
    end

    it '#find_all_by_result returns array of transactions with matching status' do

      expect(transaction_repo.find_all_by_result(:success).length).to eq(4158)
      expect(transaction_repo.find_all_by_result(:failed).length).to eq(827)
      expect(transaction_repo.find_all_by_result(:other)).to eq([])
    end

    it '#update can update existing transaction' do
      attributes = {
        :credit_card_number => "4242424242424242",
        :credit_card_expiration_date => "0220",
        :result => "success",
      }
      transaction_repo.update(100, attributes)
      expected = transaction_repo.find_by_id(100)

      expect(expected.credit_card_number).to eq("4242424242424242")
      expect(expected.updated_at).not_to eq(expected.created_at)
    end
  end

end

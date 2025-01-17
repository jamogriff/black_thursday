require_relative '../lib/sales_engine'
require_relative '../lib/customer_repository'

RSpec.describe CustomerRepository do
  sales_engine = SalesEngine.from_csv({
                                        :items     => "./data/items.csv",
                                        :merchants => "./data/merchants.csv",
                                        :invoices => "./data/invoices.csv",
                                        :customers => "./data/customers.csv",
                                        :invoice_items => "./data/invoice_items.csv",
                                        :transactions => "./data/transactions.csv"
                                        })

  customer_repo = sales_engine.customers

  describe 'initialization' do
    it 'exists' do
      expect(customer_repo).to be_instance_of(CustomerRepository)
    end

    it 'can create customer objects' do
      expect(customer_repo.array_of_objects[0]).to be_instance_of(Customer)
    end
  end

  describe 'parent class methods' do
    it '#all returns array of all customers' do
      expect(customer_repo.all.length).to eq(1000)
    end

    it '#find_by_id returns an instance by matching id' do
      id = 50

      expect(customer_repo.find_by_id(id).id).to eq(id)
      expect(customer_repo.find_by_id(id).first_name).to eq("Brent")
    end

    it '#create creates new instance with id incremented by one' do
      attributes = {
        :first_name => "Joan",
        :last_name => "Clarke",
        :created_at => Time.now,
        :updated_at => Time.now
      }
      customer_repo.create(attributes, Customer)

      expect(customer_repo.all.length).to eq(1001)
      expect(customer_repo.all.last).to be_an_instance_of(Customer)
      expect(customer_repo.all.last.last_name).to eq("Clarke")
      expect(customer_repo.all.last.id).to eq(1001)
    end

    it '#delete can delete customer' do
      customer_repo.delete(1001)
      expected = customer_repo.find_by_id(1001)
      expect(expected).to eq(nil)
    end
  end

  describe 'instance methods' do
    it '#find_all_by_first_name returns array of customers with given first name, case insensitive' do
      real_first_name = "DAMIAN"
      fake_first_name = "Aliya"

      expect(customer_repo.find_all_by_first_name(real_first_name).length).to eq(1)
      expect(customer_repo.find_all_by_first_name(fake_first_name)).to eq([])
    end

    it '#find_all_by_last_name returns array of customers with given last name, case insensitive' do
      real_last_name = "BARROWS"
      fake_last_name = "Merali"

      expect(customer_repo.find_all_by_last_name(real_last_name).length).to eq(3)
      expect(customer_repo.find_all_by_last_name(fake_last_name)).to eq([])
    end

    it '#update can update existing customer' do
      attributes = {
        :first_name => "Joan",
        :last_name => "Clarke"
      }
      customer_repo.update(100, attributes)
      expected = customer_repo.find_by_id(100)

      expect(expected.last_name).to eq("Clarke")
      expect(expected.updated_at).not_to eq(expected.created_at)
    end
  end
end

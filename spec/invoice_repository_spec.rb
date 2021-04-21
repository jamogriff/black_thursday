require_relative '../lib/sales_engine'
require_relative '../lib/invoice_repository'

RSpec.describe InvoiceRepository do
  sales_engine = SalesEngine.from_csv({
                                        :items     => "./data/items.csv",
                                        :merchants => "./data/merchants.csv",
                                        :invoices => "./data/invoices.csv",
                                        :customers => "./data/customers.csv",
                                        :invoice_items => "./data/invoice_items.csv",
                                        :transactions => "./data/transactions.csv"
                                        })

  invoice_repo = sales_engine.invoices

  describe 'initialization' do
    it 'exists' do
      expect(invoice_repo).to be_instance_of(InvoiceRepository)
    end

    it 'can create invoice objects' do
      expect(invoice_repo.array_of_objects[0]).to be_instance_of(Invoice)
    end
  end

  describe 'parent class methods' do
    it '#all returns array of all invoices' do
      expect(invoice_repo.all.length).to eq(4985)
    end

    it '#find_by_id returns an instance by matching id' do
      id = 3452

      expect(invoice_repo.find_by_id(id).id).to eq(id)
      expect(invoice_repo.find_by_id(id).status).to eq(:pending)
    end

    it '#create creates new instance with id one higher than highest' do
      attributes = {
                    :customer_id => 7,
                    :merchant_id => 8,
                    :status      => "pending",
                    :created_at  => Time.now,
                    :updated_at  => Time.now,
                  }

      invoice_repo.create(attributes, Invoice)

      expect(invoice_repo.all.length).to eq(4986)
      expect(invoice_repo.all.last).to be_an_instance_of(Invoice)
      expect(invoice_repo.all.last.status).to eq(:pending)
      expect(invoice_repo.all.last.id).to eq(4986)
    end

    it '#delete can delete invoice' do
      invoice_repo.delete(3452)
      expected = invoice_repo.find_by_id(3452)
      expect(expected).to eq(nil)
    end
  end

  describe 'instance methods' do
    it '#find_all_by_customer_id returns array of invoices with customer id' do
      real_customer_id = 300
      fake_customer_id = 10000

      expect(invoice_repo.find_all_by_customer_id(real_customer_id).length).to eq(10)
      expect(invoice_repo.find_all_by_customer_id(fake_customer_id)).to eq([])
    end

    it '#find_all_by_merchant_id returns array of invoices with merchant id' do
      real_merchant_id = 12335080
      fake_merchant_id = 10000

      expect(invoice_repo.find_all_by_merchant_id(real_merchant_id).length).to eq(7)
      expect(invoice_repo.find_all_by_merchant_id(fake_merchant_id)).to eq([])
    end

    it '#find_all_by_status returns array of invoices with matching status' do

      expect(invoice_repo.find_all_by_status(:shipped).length).to eq(2839)
      expect(invoice_repo.find_all_by_status(:pending).length).to eq(1473)
      expect(invoice_repo.find_all_by_status(:sold)).to eq([])
    end

    it '#update can update existing invoice' do
      attributes = {
        :status => "paid"
      }
      invoice_repo.update(4986, attributes)
      expected = invoice_repo.find_by_id(4986)

      expect(expected.status).to eq("paid")
      expect(expected.updated_at).not_to eq(expected.created_at)
    end
  end
end

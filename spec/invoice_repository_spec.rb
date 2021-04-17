require_relative '../lib/sales_engine'
require_relative '../lib/invoice_repository'
require_relative '../lib/merchant'
require_relative '../lib/merchant_repository'
require_relative '../lib/item_repository'
require_relative '../lib/item'
require 'bigdecimal/util'

RSpec.describe InvoiceRepository do
  describe 'initialization' do
    sales_engine = SalesEngine.from_csv({
                              :items     => "./data/items.csv",
                              :merchants => "./data/merchants.csv",
                              :invoices => "./data/invoices.csv"
                              })
    invoice_repo = sales_engine.invoices

    it 'exists' do
      expect(invoice_repo).to be_instance_of(InvoiceRepository)
    end

    it 'can create invoice objects' do
      expect(invoice_repo.array_of_objects[0]).to be_instance_of(Invoice)
    end
  end

  describe 'all method' do
    sales_engine = SalesEngine.from_csv({
                              :items     => "./data/items.csv",
                              :merchants => "./data/merchants.csv",
                              :invoices => "./data/invoices.csv"
                              })
    invoice_repo = sales_engine.invoices

    it 'returns array of all invoices' do
      expect(invoice_repo.all.length).to eq(4985)
    end
  end

  describe 'various find methods' do
    sales_engine = SalesEngine.from_csv({
                              :items     => "./data/items.csv",
                              :merchants => "./data/merchants.csv",
                              :invoices => "./data/invoices.csv"
                              })
    invoice_repo = sales_engine.invoices

    it 'find_by_id returns an instance by matching id' do
      id = 3452

      expect(invoice_repo.find_by_id(id).id).to eq(id)
      expect(invoice_repo.find_by_id(id).status).to eq(:pending)
    end
  end

  describe '#delete' do
    sales_engine = SalesEngine.from_csv({
                              :items     => "./data/items.csv",
                              :merchants => "./data/merchants.csv",
                              :invoices => "./data/invoices.csv"
                              })
    invoice_repo = sales_engine.invoices

    it 'can delete invoice' do
      invoice_repo.delete(3452)
      expected = invoice_repo.find_by_id(3452)
      expect(expected).to eq(nil)
    end
  end

  describe '#create' do
    sales_engine = SalesEngine.from_csv({
                              :items     => "./data/items.csv",
                              :merchants => "./data/merchants.csv",
                              :invoices => "./data/invoices.csv"
                              })
    invoice_repo = sales_engine.invoices

    attributes = {
                  :customer_id => 7,
                  :merchant_id => 8,
                  :status      => "pending",
                  :created_at  => Time.now,
                  :updated_at  => Time.now,
                }

    invoice_repo.create(attributes)

    it 'creates new instance with attribute argument' do

      expect(invoice_repo.all.length).to eq(4986)
      expect(invoice_repo.all.last).to be_an_instance_of(Invoice)
      expect(invoice_repo.all.last.status).to eq(:pending)
    end

    it 'new instance id is the highest id incremented by one' do

      expect(invoice_repo.all.last.id).to eq(4986)
    end
  end

  describe '#update' do
    sales_engine = SalesEngine.from_csv({
                              :items     => "./data/items.csv",
                              :merchants => "./data/merchants.csv",
                              :invoices => "./data/invoices.csv"
                              })
    invoice_repo = sales_engine.invoices

    attributes = {
                  :status => "paid"
                }

    invoice_repo.update(id, attributes)

    it 'can update existing invoice' do
      invoice_repo.update(3452, attributes)
      expected = invoice_repo.find_by_id(3452)
      expect(expected.status).to eq("paid")
      expect(expected.updated_at).not_to eq(expected.created_at)
    end
  end
end

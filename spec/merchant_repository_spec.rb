require './lib/sales_engine'
require './lib/merchant_repository'
# require 'simplecov'
RSpec.describe MerchantRepository do

  # Parameter (array of hashes) should be passed
  # into new instance
  xdescribe 'initialization' do
    merch_rep = MerchantRepository.new()

    it 'exists' do
      expect(merch_rep).to be_instance_of(MerchantRepository)
    end

  end
end
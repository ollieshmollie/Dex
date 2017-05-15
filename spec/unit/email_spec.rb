require_relative '../spec_helper'

RSpec.describe Tact::Email do
  let(:email) { Tact::Email.new(address: 'test@test.com') }

  describe 'attributes' do

    it 'has an address' do
      expect(email.address).to eq 'test@test.com'
    end
  end

  describe 'associations' do
    
    it 'belongs to contact' do
      expect(email).to respond_to(:contact)
    end
  end
end


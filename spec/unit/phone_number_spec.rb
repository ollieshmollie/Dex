require_relative '../spec_helper'

RSpec.describe Tact::PhoneNumber do
  let(:number) { Tact::PhoneNumber.new(number: '1234567890', kind: 'Test') }

  describe 'attributes' do

    it 'has a number' do
      expect(number.number).to eq '1234567890'
    end

    it 'has a kind' do
      expect(number.kind).to eq 'Test'
    end
  end

  describe 'associations' do
    
    it 'belongs to contact' do
      expect(number).to respond_to(:contact)
    end
  end
end

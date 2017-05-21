require_relative '../spec_helper'

RSpec.describe Tact::PhoneNumber do
  let(:number) { Tact::PhoneNumber.new(number: '1234567890', kind: 'Test') }

  describe 'attributes' do

    it 'has a number' do
      expect(number.number).to eq '(123) 456-7890'
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

  describe 'formatting' do
    let(:correct_num) { '(123) 456-7890' }

    after(:each) do
      expect(number.format_number).to eq correct_num
    end

    it 'correctly formats a number with a country code' do
      number.number = '+11234567890' 
    end

    it 'correctly formats a number with eleven digits' do
      number.number = '11234567890'
    end

    it 'correctly formats a number with eleven digits and dashes' do
      number.number = '1-123-456-7890'
    end

    it 'correctly formats a foreign number' do
      number.number = '+44-123-456-7890' 
    end
  end
end

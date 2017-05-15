require_relative '../spec_helper'

RSpec.describe Tact::Contact do
  let(:contact) { Tact::Contact.new(first_name: "Testy", last_name: "McTesterton") }

  describe 'attributes' do

    it 'has a first name' do
      expect(contact.first_name).to eq 'Testy'
    end

    it 'has a last name' do
      expect(contact.last_name).to eq 'McTesterton'
    end

    it 'has a full name' do
      expect(contact.full_name).to eq 'Testy McTesterton'
    end
  end

  describe 'associations' do
    
    it 'has many phone_numbers' do
      expect(contact).to respond_to(:phone_numbers)
      expect(contact.phone_numbers).to respond_to(:count)
    end

    it 'has many emails' do
      expect(contact).to respond_to(:emails)
      expect(contact.emails).to respond_to(:count)
    end
  end

  describe 'database operations' do
    
    before(:each) do
      contact.save
    end

    it "capitalizes all letters in name" do
      expect(contact.full_name).to eq 'TESTY MCTESTERTON'
    end
  end
end

require_relative '../spec_helper'

RSpec.describe Tact::GoogleContacts::Syncer do
  let(:info) { CONTACT_INFO }
  let(:entry) { Tact::GoogleContacts::Entry.new(info) }
  let(:syncer) { Tact::GoogleContacts::Syncer.new(entry) }


  context 'with an existing contact' do
    let!(:contact) do
      Tact::Contact.create(first_name: 'Testy', last_name: 'McTesterton')  
    end 

    it 'finds an existing contact' do
      expect(syncer.find_contact).to eq contact
    end

    it 'adds phone numbers from google to contact' do
      syncer.sync
      number = contact.phone_numbers.first
      expect(number.number).to eq '(123) 456-7890'
      expect(number.kind).to eq 'Cell'
    end

    it 'does not add repeat numbers' do
      contact.phone_numbers << Tact::PhoneNumber.new(
        number: '1234567890',
        kind: 'Cell'
      )
      contact.save
      expect { syncer.sync }.not_to change(Tact::PhoneNumber, :count)
    end

    it 'adds emails from google to contact' do
      syncer.sync
      email = contact.emails.first
      expect(email.address).to eq 'test@test.com'
    end

    it 'does not add repeat emails' do
      contact.emails << Tact::Email.new(address: 'test@test.com')
      contact.save
      expect { syncer.sync }.not_to change(Tact::Email, :count)
    end
  end

  context 'with a nonexisting contact' do

    it 'does not find a contact' do
      expect(syncer.find_contact).to be nil
    end

    it 'creates a new contact' do
      expect { syncer.sync }.to change(Tact::Contact, :count).by 1
      contact = Tact::Contact.first
      expect(contact.full_name).to eq 'TESTY MCTESTERTON'
      expect(contact.phone_numbers.first.number).to eq '(123) 456-7890'
      expect(contact.emails.first.address).to eq 'test@test.com'
    end
  end
end

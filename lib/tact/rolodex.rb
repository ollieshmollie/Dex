require 'sqlite3'
require 'colored'
require_relative 'card'
require_relative 'database'

module Tact
  class Rolodex
    
    def initialize
      @cards = load_cards
      @db = Database.new.db
    end

    def load_cards
      cards = Contact.all.each_with_index.map do |contact, index|
        contact.index = index + 1
        Card.new(contact)
      end
      cards
    end

    def add_contact(first_name, last_name)
      Contact.new(first_name, last_name).save
    end

    def add_phone_number(contact_index, type, number)
      contact = find_contact(contact_index)
      PhoneNumber.new(type, number, contact.id).save
    end

    def add_email(contact_index, address)
      contact = find_contact(contact_index)
      Email.new(address, contact.id).save
    end

    def delete_contact(contact_index)
      contact = find_contact(contact_index)
      Contact.delete(contact.id)
    end

    def delete_phone_number(contact_index, num_index)
      phone_number = find_phone_number(contact_index, num_index)
      PhoneNumber.delete(phone_number.id)
    end

    def delete_email(contact_index, email_index)
      email = find_email(contact_index, email_index)
      Email.delete(email.id)
    end

    def edit_contact_name(contact_index, new_first_name, new_last_name)
      contact = find_contact(contact_index)
      contact.first_name = new_first_name.downcase.capitalize
      contact.last_name = new_last_name.downcase.capitalize
      contact.save
    end

    def edit_phone_number(contact_index, num_index, new_type, new_number)
      new_type = new_type.downcase.capitalize
      new_number = new_number.gsub(/\D/, "")
      phone_number = find_phone_number(contact_index, num_index)
      phone_number.type = new_type
      phone_number.number = new_number
      phone_number.save
    end

    def edit_email(contact_index, email_index, new_address)
      email = find_email(contact_index, email_index)
      email.address = new_address
      email.save
    end

    def find_contact(contact_index)
      begin 
        @cards[contact_index - 1].contact
      rescue 
        puts "Error: Contact index out of range".red
        exit
      end
    end

    def find_phone_number(contact_index, num_index)
      contact = find_contact(contact_index)
      phone_number = contact.phone_numbers[num_index - 1]
      if phone_number then phone_number
      else 
        puts "Error: Phone number index out of range".red
        exit
      end
    end

    def find_email(contact_index, email_index)
      contact = find_contact(contact_index)
      email = contact.emails[email_index - 1]
      if email then email
      else
        puts "Error: Email index out of range".red
        exit
      end
    end

    def find_by_name(param)
      param = param.split(" ").map {|name| name.capitalize }.join(" ")
      search_results = []
      @cards.each {|card| search_results.push(card) if card.contact.full_name.include?(param)}
      search_results
    end

    def find_by_number(param)
      contact_ids = @db.execute("select distinct contact_id from phone_numbers where number like '%#{param}%';")
      contact_ids.map {|hash| convert_to_card(hash["contact_id"]) } 
    end

    def find_by_email(param)
      contact_ids = @db.execute("select distinct contact_id from emails where address like '%#{param}%';")
      contact_ids.map {|hash| convert_to_card(hash["contact_id"]) }
    end

    def convert_to_card(contact_id)
      results = @cards.select {|card| card.contact.id == contact_id }
      results[0]
    end

    def to_s
      string = ""
      @cards.each {|card| string += card.to_s}
      string
    end
  end
end

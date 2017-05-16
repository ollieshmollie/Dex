module Tact
  class Rolodex
    
    def initialize
      @cards = load_cards
    end

    def load_cards
      cards = Contact.all.order(last_name: :asc, first_name: :asc).each_with_index.map do |contact, index|
        Card.new(contact, index + 1)
      end
      cards
    end

    def add_contact(first_name, last_name)
      begin
        Contact.create!(
          first_name: first_name,
          last_name: last_name
        )
      rescue
        puts 'Error: Contact already exists'.red
      end
    end

    def add_phone_number(contact_index, kind, number)
      contact = find_contact(contact_index)
      PhoneNumber.create(
        kind: kind,
        number: number,
        contact: contact
      )
    end

    def add_email(contact_index, address)
      contact = find_contact(contact_index)
      Email.create(
        address: address, 
        contact: contact
      )
    end

    def delete_contact(contact_index)
      find_contact(contact_index).destroy
    end

    def delete_phone_number(contact_index, num_index)
      find_phone_number(contact_index, num_index).destroy
    end

    def delete_email(contact_index, email_index)
      find_email(contact_index, email_index).destroy
    end

    def edit_contact_name(contact_index, new_first_name, new_last_name)
      contact = find_contact(contact_index)
      contact.update_attributes(
        first_name: new_first_name,
        last_name: new_last_name
      )
    end

    def edit_phone_number(contact_index, num_index, new_type, new_number)
      phone_number = find_phone_number(contact_index, num_index)
      phone_number.update_attributes(
        type: new_type,
        number: new_number
      )
    end

    def edit_email(contact_index, email_index, new_address)
      email = find_email(contact_index, email_index)
      email.update_attributes(address: new_address)
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

    # TODO: Add specs for find methods
    def find_by_name(param)
      param = param.split(" ").map {|name| name.upcase }.join(" ")
      search_results = []
      @cards.each {|card| search_results.push(card) if card.contact.full_name.include?(param)}
      search_results
    end

    def find_by_number(param)
      phone_numbers = PhoneNumber.includes(:contact).where('number LIKE ?', "%#{param}%")
      phone_numbers.map do |phone_number|
        convert_to_card(phone_number.contact.id)
      end
    end

    def find_by_email(param)
      emails = Email.includes(:contact).where('address LIKE ?', "%#{param}%")
      emails.map do |email|
        convert_to_card(email.contact.id)
      end
    end

    def convert_to_card(contact_id)
      results = @cards.select {|card| card.contact.id == contact_id }
      results[0]
    end

    def length
      @cards.count
    end

    def to_s
      string = ""
      @cards.each {|card| string += card.to_s}
      string
    end
  end
end

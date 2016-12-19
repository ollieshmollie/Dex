require 'sqlite3'
require 'colored'
require_relative 'card'
require_relative 'database'

module Tact
  class Rolodex
    
    def initialize
      @cards = Contact.all.map {|contact| Card.new(contact) }
      @db = Database.new
    end

    def add_contact(first_name, last_name)
      first_name = first_name.downcase.capitalize
      last_name = last_name.downcase.capitalize
      begin
        @db.execute("insert into contacts (first_name, last_name)"\
                  "values ('#{first_name}', '#{last_name}');")
      rescue
        puts "Error: Contact already exists".red
      end
    end

    def add_phone_number(contact_index, type, number)
      type = type.downcase.capitalize
      number = number.gsub(/\D/, "")
      contact_id = contact_id(contact_index)
      @db.execute("insert into phone_numbers (type, number, contact_id) values ('#{type}', '#{number}', #{contact_id});")
    end

    def add_email(contact_index, address)
      contact_id = contact_id(contact_index)
      @db.execute("insert into emails (address, contact_id) values ('#{address}', #{contact_id});")
    end

    def delete_contact(contact_index)
      contact_id = contact_id(contact_index)
      @db.execute("delete from contacts where id = #{contact_id};")
    end

    def delete_phone_number(contact_index, num_index)
      phone_number_id = phone_number_id(contact_index, num_index)
      @db.execute("delete from phone_numbers where id = #{phone_number_id};")
    end

    def delete_email(contact_index, email_index)
      email_id = email_id(contact_index, email_index)
      @db.execute("delete from emails where id = #{email_id};")
    end

    def edit_contact_name(contact_index, new_first_name, new_last_name)
      new_first_name = new_first_name.downcase.capitalize
      new_last_name = new_last_name.downcase.capitalize
      contact_id = contact_id(contact_index)  
      begin
        @db.execute("update contacts "\
                    "set first_name = '#{new_first_name}', "\
                    "last_name = '#{new_last_name}' "\
                    "where id = #{contact_id};")
      rescue
        puts "Error: Contact already exists".red
      end
    end

    def edit_phone_number(contact_index, num_index, new_type, new_number)
      new_type = new_type.downcase.capitalize
      new_number = new_number.gsub(/\D/, "")
      phone_number_id = phone_number_id(contact_index, num_index)
      @db.execute("update phone_numbers "\
                  "set type = '#{new_type}', "\
                  "number = '#{new_number}' "\
                  "where id = #{phone_number_id};")
    end

    def edit_email(contact_index, email_index, new_address)
      email_id = email_id(contact_index, email_index)
      @db.execute("update emails "\
                  "set address = '#{new_address}' "\
                  "where id = #{email_id};")
    end

    def phone_number_id(contact_index, num_index)
      contact = check_contact_index(contact_index)
      begin
        contact.phone_numbers[num_index - 1].primary_key
      rescue
        puts "Error: Phone number index out of range".red
      end
    end

    def email_id(contact_index, email_index)
      contact = check_contact_index(contact_index)
      begin
        contact.emails[email_index - 1].primary_key
      rescue
        puts "Error: Email index out of range".red
      end
    end

    def contact_id(contact_index)
      begin
        contact = @contacts[contact_index - 1]
        contact.primary_key
      rescue
        puts "Error: Contact index out of range".red
        exit
      end
    end

    def check_contact_index(contact_index)
      begin
        @contacts[contact_index - 1]
      rescue
        puts puts "Error: Contact index out of range".red
        exit
      end
    end

    def find_by_name(param)
      param = param.split(" ").map {|name| name.capitalize }.join(" ")
      search_results = []
      @contacts.each {|contact| search_results.push(contact) if contact.full_name.include?(param)}
      search_results
    end

    def find_by_number(param)
      contact_ids = @db.execute("select distinct contact_id from phone_numbers where number like '%#{param}%';")
      contact_ids.map {|hash| convert_to_contact(hash["contact_id"]) } 
    end

    def find_by_email(param)
      contact_ids = @db.execute("select distinct contact_id from emails where address like '%#{param}%';")
      contact_ids.map {|hash| convert_to_contact(hash["contact_id"]) }
    end

    def convert_to_contact(contact_id)
      results = @contacts.select {|contact| contact.primary_key == contact_id }
      results[0]
    end

    def to_s
      string = ""
      @cards.each {|card| string += card.to_s}
      string
    end
  end
end

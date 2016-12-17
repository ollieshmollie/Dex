require 'sqlite3'
require 'colored'
require_relative 'contact.rb'

module Tact
  class Rolodex
    attr_reader :contacts, :db_path
    
    def initialize
      home_dir = File.expand_path("~")
      Dir.mkdir("#{home_dir}/.tact") unless File.exists?("#{home_dir}/.tact")
      @db = SQLite3::Database.new("#{File.expand_path("~")}/.tact/tact.sqlite3")
      @db.results_as_hash = true
      @db.execute("pragma foreign_keys = on")
      create_tables
      @contacts = load
    end

    def create_tables
      contact_table = <<~eof
        CREATE TABLE IF NOT EXISTS contacts(
          id integer primary key,
          first_name varchar(255) not null,
          last_name varchar(255) not null,
          constraint name_unique unique (first_name, last_name)
        );
        eof
      phone_numbers_table = <<~eof
        CREATE TABLE IF NOT EXISTS phone_numbers(
          id integer primary key,
          type varchar(255),
          number varchar(255),
          contact_id int,
          foreign key (contact_id) references contacts(id) on delete cascade
        );
        eof
      emails_table = <<~eof
        CREATE TABLE IF NOT EXISTS emails(
          id integer primary key,
          address varchar(255),
          contact_id,
          foreign key (contact_id) references contacts(id) on delete cascade
        );
        eof
      @db.execute(contact_table)
      @db.execute(phone_numbers_table)
      @db.execute(emails_table)
    end

    def load
      contacts = []
      contact_index = 1
      @db.execute("select * from contacts order by last_name asc, first_name asc;") do |contact_hash|
        contact = Contact.from_hash(contact_hash)
        contact.index = contact_index
        num_index = 1
        @db.execute("select * from phone_numbers where contact_id = #{contact_hash["id"]} order by type asc;") do |phone_number_hash|
          number = PhoneNumber.from_hash(phone_number_hash)
          number.index = num_index
          contact.phone_numbers << number
          num_index += 1
        end
        email_index = 1
        @db.execute ("select * from emails where contact_id = #{contact_hash["id"]} order by address asc;") do |email_hash|
          email = Email.from_hash(email_hash)
          email.index = email_index
          contact.emails << email
          email_index += 1
        end
        contacts << contact
        contact_index += 1
        num_index = 1
        email_index = 1
      end
      return contacts
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
      @contacts.each {|contact| string += contact.to_s}
      return string
    end
  end
end

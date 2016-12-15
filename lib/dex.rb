require_relative "./contact.rb"
require 'sqlite3'

class Dex
  attr_reader :contacts
  
  def initialize
    @db = SQLite3::Database.new("/Users/ollieshmollie/Projects/Ruby/dex/dex.sqlite3")
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
    contact_index = 0
    @db.execute("select * from contacts order by last_name asc;") do |contact_hash|
      contact = Contact.from_hash(contact_hash)
      contact.index = contact_index
      num_index = 0
      @db.execute("select * from phone_numbers where contact_id = #{contact_hash["id"]};") do |phone_number_hash|
        number = PhoneNumber.from_hash(phone_number_hash)
        number.index = num_index
        contact.phone_numbers << number
        num_index += 1
      end
      email_index = 0
      @db.execute ("select * from emails where contact_id = #{contact_hash["id"]};") do |email_hash|
        email = Email.from_hash(email_hash)
        email.index = email_index
        contact.emails << email
        email_index += 1
      end
      contacts << contact
      contact_index += 1
      num_index = 0
      email_index = 0
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
    contact_id = contact_id(contact_index)
    begin
      phone_numbers = @db.execute("select * from phone_numbers where contact_id = #{contact_id}")
      phone_number_id = phone_numbers[num_index]["id"]
      @db.execute("delete from phone_numbers where id = #{phone_number_id};")
    rescue
      puts "Error: Phone number index out of range".red
    end
  end

  def delete_email(contact_index, email_index)
    contact_id = contact_id(contact_index)
    begin
      emails = @db.execute("select * from emails where contact_id = #{contact_id};")
      email_id = emails[email_index]["id"]
      @db.execute("delete from emails where id = #{email_id};")
    rescue
      puts "Error: Email index out of range".red
    end
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
    contact_id = contact_id(contact_index)
    begin
      phone_numbers = @db.execute("select * from phone_numbers where contact_id = #{contact_id}")
      phone_number_id = phone_numbers[num_index]["id"]
      @db.execute("update phone_numbers "\
                  "set type = '#{new_type}', "\
                  "number = '#{new_number}' "\
                  "where id = #{phone_number_id};")
    rescue
      puts "Error: Phone number index out of range".red
    end
  end

  def edit_email(contact_index, email_index, new_address)
    contact_id = contact_id(contact_index)
    begin
      emails = @db.execute("select * from emails where contact_id = #{contact_id};")
      email_id = emails[email_index]["id"]
      @db.execute("update emails "\
                  "set address = '#{new_address}' "\
                  "where id = #{email_id};")
    rescue
      puts "Error: Email index out of range".red
    end
  end

  def contact_id(contact_index)
    begin
      contact = @contacts[contact_index]
      id_arr = @db.execute("select id from contacts where first_name = '#{contact.first_name}' and last_name = '#{contact.last_name}';")
      id_arr[0]["id"]
    rescue
      puts "Error: Contact index out of range".red
      exit
    end
  end

  def find_by_name(param)
    param = param.downcase.capitalize
    search_results = []
    contacts.each {|contact| search_results.push(contact) if contact.full_name.include?(param)}
    search_results
  end

  def find_by_number(param)
    param = PhoneNumber.format_number(param)
    search_results = []
    contacts.each do |contact|
      contact.phone_numbers.each {|number| search_results.push(contact) if number.number.include?(param)}
    end
    search_results
  end

  def find_by_email(param)
    param = param.downcase.capitalize
    search_results = []
    contacts.each do |contact|
      contact.emails.each {|email| search_results.push(contact) if email.address.include?(param)}
    end
    search_results
  end

  def to_s
    string = ""
    contacts.each {|contact| string += contact.to_s}
    return string
  end
end
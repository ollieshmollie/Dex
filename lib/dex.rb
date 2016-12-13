require_relative "./contact.rb"
require 'sqlite3'

class Dex
  attr_reader :contacts
  
  def initialize
    @db = SQLite3::Database.new('dex.sqlite3')
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
    @db.results_as_hash = true
    @db.execute("select * from contacts order by last_name asc;") do |contact_hash|
      contact = Contact.from_hash(contact_hash)
      contact.index = contact_index
      phone_number_index = 0
      @db.execute("select * from phone_numbers where contact_id = #{contact_hash["id"]};") do |phone_number_hash|
        number = PhoneNumber.from_hash(phone_number_hash)
        number.index = phone_number_index
        contact.phone_numbers << number
        phone_number_index += 1
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
      phone_number_index = 0
      email_index = 0
    end
    return contacts
  end

  def add_contact(first_name, last_name)
    first_name = first_name.downcase.capitalize
    last_name = last_name.downcase.capitalize
    return false if @db.execute("select * from contacts where first_name = '#{first_name}' and last_name = '#{last_name}';").length > 0
    @db.execute("insert into contacts (first_name, last_name)"\
                "values ('#{first_name}', '#{last_name}');")
    true
  end

  def add_phone_number(contact_index, type, number)
    type = type.downcase.capitalize
    contact_id = contact_id(contact_index)
    return true if @db.execute("insert into phone_numbers (type, number, contact_id) values ('#{type}', '#{number}', #{contact_id});")
    false
  end

  def add_email(contact_index, address)
    contact_id = contact_id(contact_index)
    return true if @db.execute("insert into emails (address, contact_id) values ('#{address}', #{contact_id});")
    false
  end

  def delete_contact(contact_index)
    contact_id = contact_id(contact_index)
    return true if @db.execute("delete from contacts where id = #{contact_id};")
    false
  end

  def delete_phone_number(contact_index, phone_number_index)
    contact_id = contact_id(contact_index)
    phone_numbers = @db.execute("select * from phone_numbers where contact_id = #{contact_id}")
    phone_number_id = phone_numbers[phone_number_index]["id"]
    return true if @db.execute("delete from phone_numbers where id = #{phone_number_id};")
    false
  end

  def delete_email(contact_index, email_index)
    contact_id = contact_id(contact_index)
    emails = @db.execute("select * from emails where contact_id = #{contact_id};")
    email_id = emails[email_index]["id"]
    return true if @db.execute("delete from emails where id = #{email_id};")
    false
  end

  def contact_id(contact_index)
    contact = @contacts[contact_index]
    id_arr = @db.execute("select id from contacts where first_name = '#{contact.first_name}' and last_name = '#{contact.last_name}';")
    id_arr[0]["id"]
  end

  def find_by_first_name_letter(letter)
    search_results = []
    contacts.each {|contact| search_results.push(contact) if contact.first_name.start_with?(letter.upcase)}
    return search_results.empty? ? "No search results found".red : search_results
  end

  def find_by_last_name_letter(letter)
    search_results = []
    contacts.each {|contact| search_results.push(contact) if contact.last_name.start_with?(letter.upcase)}
    return search_results.empty? ? "No search results found".red : search_results
  end

  def find_by_name(param)
    search_results = []
    contacts.each {|contact| search_results.push(contact) if contact.full_name.include?(param)}
    return search_results.empty? ? "No search results found".red : search_results
  end

  def find_by_number(param)
    search_results = []
    contacts.each do |contact|
      contact.phone_numbers.each {|number| search_results.push(contact) if number.number.include?(param)}
    end
    return search_results.empty? ? "No search results found".red : search_results
  end

  def find_by_email(param)
    search_results = []
    contacts.each do |contact|
      contact.emails.each {|email| search_results.push(contact) if email.address.include?(param)}
    end
    return search_results.empty? ? "No search results found".red : search_results
  end

  def add(contact)
    contacts.push(contact)
    save
    return contact
  end

  def delete(contact_index)
    if contact_index >= 0 && contact_index < contacts.count
      contact = contacts[contact_index]
      contacts.delete_at(contact_index)
      save
      return contact
    end
  end

  def contact_at_index(index)
    if index >= 0 && index < contacts.count
      return contacts[index]
    end
  end

  def to_s
    string = ""
    contacts.each {|contact| string += contact.to_s}
    return string
  end
end
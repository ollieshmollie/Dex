require_relative "./contact.rb"
require 'pp'
require 'sqlite3'

class Dex
  attr_reader :contacts
  
  def initialize
    @contacts = load
  end

  def load
    contacts = []
    SQLite3::Database.new("dex.sqlite3") do |db|
      db.results_as_hash = true
      contact_index = 0
      db.execute("select * from contacts;") do |contact_hash|
        contact = Contact.from_hash(contact_hash)
        contact.index = contact_index
        phone_number_index = 0
        db.execute("select * from phone_numbers where contact_id = #{contact_hash["id"]};") do |phone_number_hash|
          number = PhoneNumber.from_hash(phone_number_hash)
          number.index = phone_number_index
          contact.phone_numbers << number
          phone_number_index += 1
        end
        email_index = 0
        db.execute ("select * from emails where contact_id = #{contact_hash["id"]};") do |email_hash|
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
    end
    return contacts
  end

  def save
    dex = []
    contacts.sort!
    contacts.each_with_index do |contact, index|
      contact.index = index
      dex.push(contact.to_hash)
    end
    File.open("/Users/ollieshmollie/Projects/Ruby/Dex/contacts.json", "w") do |file|
      file.write(JSON.pretty_generate(dex))
    end
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
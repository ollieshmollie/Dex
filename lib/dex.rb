require_relative "./contact.rb"
require 'json'

class Dex

  attr_reader :contacts
  def initialize
    @contacts = load || []
  end

  def load
    if File.exists?("./contacts.json")
      file = File.open("./contacts.json").read
      dex = JSON.parse(file)
      loadedContacts = []
      dex.each do |hash|
        contact = Contact.from_hash(hash)
        loadedContacts.push(contact)
      end
      return loadedContacts
    end
  end

  def find_by_name(param)
    param = param
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

  def save
    dex = []
    contacts.sort!
    contacts.each_with_index do |contact, index| 
      contact.index = index
      dex.push(contact.to_hash)
    end
    File.open("./contacts.json", "w") do |file|
      file.write(JSON.pretty_generate(dex))
    end
  end

  def to_s
    string = ""
    contacts.each {|contact| string += contact.to_s}
    return string
  end

end
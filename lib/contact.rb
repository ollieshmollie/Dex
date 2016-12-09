require_relative "./phone_number.rb"
require_relative "./email.rb"
require 'colored'

class Contact
  include Comparable
  attr_accessor :index, :first_name, :last_name, :phone_numbers, :emails

  def <=>(another_contact)
    full_name <=> another_contact.full_name
  end

  def initialize(first_name, last_name)
    @index = nil
    @first_name = first_name.capitalize
    @last_name = last_name.capitalize
    @phone_numbers = []
    @emails = []
  end

  def self.from_hash(hash)
    contact = self.new(hash["first_name"], hash["last_name"])
    contact.index = hash["index"]
    phone_numbers = hash["phone_numbers"]
    phone_numbers.each do |hash| 
      number = PhoneNumber.from_hash(hash)
      contact.phone_numbers.push(number)
    end
    emails = hash["emails"]
    emails.each do |hash|
      email = Email.from_hash(hash)
      contact.emails.push(email)
    end
    return contact
  end

  def to_hash
    phone_numbers.sort!
    emails.sort!
    numbers = []
    addresses = []
    phone_numbers.each_with_index do |number, index|
      number.index = index 
      numbers.push(number.to_hash)
    end
    emails.each_with_index do |email, index|
      email.index = index
      addresses.push(email.to_hash)
    end
    {index: index, first_name: first_name, last_name: last_name, phone_numbers: numbers, emails: addresses}
  end

  def full_name
    first_name + " " + last_name
  end

  def add_phone_number(type, number)
    phone_numbers.push(PhoneNumber.new(type.capitalize, number))
  end

  def delete_phone_number(number_index)
    if number_index >= 0 && number_index < phone_numbers.count
      phone_numbers.delete_at(number_index)
      return true
    end
    false
  end

  def update_phone_number(number_index, new_type, new_number)
    if number_index >= 0 && number_index < phone_numbers.count
      phone_number = phone_numbers[number_index]
      phone_number.type = new_type
      phone_number.number = new_number
      return true
    end
    false
  end

  def add_email(address)
    emails.push(Email.new(address))
  end

  def delete_email(email_index)
    if email_index >= 0 && email_index < emails.count
      emails.delete_at(email_index)
      return true
    end
    false
  end

  def update_email(email_index, new_address)
    if email_index >= 0 && email_index < emails.count
      email = emails[email_index]
      email.address = new_address
      return true
    end
    false
  end

  def to_s
    string = "=" * 40 + "\n"
    string += "[#{index}]".red + " #{full_name}\n".green.bold
    phone_numbers.each {|number| string += "\s\s" + number.to_s + "\n"}
    emails.each {|address| string += "\s\s\s\s" + address.to_s + "\n"}
    string += "=" * 40 + "\n"
    return string
  end
end
require_relative "./phone_number.rb"
require 'colored'

class Contact

  include Comparable
  attr_accessor :index, :first_name, :last_name, :phone_numbers
  def initialize(first_name, last_name)
    @index = nil
    @first_name = first_name.capitalize
    @last_name = last_name.capitalize
    @phone_numbers = []
  end

  def <=>(another_contact)
    case
    when self.first_name > another_contact.first_name
      return 1
    when self.first_name < another_contact.first_name
      return -1
    else
      return 0
    end
  end

  def self.from_hash(hash)
    contact = self.new(hash["first_name"], hash["last_name"])
    contact.index = hash["index"]
    phone_numbers = hash["phone_numbers"]
    phone_numbers.each do |hash| 
      number = PhoneNumber.from_hash(hash)
      contact.phone_numbers.push(number)
    end
    return contact
  end

  def to_hash
    phone_numbers.sort!
    numbers = []
    phone_numbers.each_with_index do |number, index|
      number.index = index
      number = number.to_hash 
      numbers.push(number.to_hash)
    end
    {index: index, first_name: first_name, last_name: last_name, phone_numbers: numbers}
  end

  def full_name
    first_name + " " + last_name
  end

  def add_phone_number(type, number)
    phone_numbers.push(PhoneNumber.new(type.capitalize, number))
  end

  def delete_phone_number(number_index)
    phone_numbers.delete_at(number_index)
  end

  def to_s
    string = "[#{index}]".red + " #{full_name}\n".green.bold
    phone_numbers.each {|number| string += "\s\s" + number.to_s + "\n"}
    return string
  end

  def to_s_with_number_index
    string = "[#{index}]".red + " #{full_name}\n".green.bold
    phone_numbers.each {|number| string += "\s\s" + number.to_s_with_index + "\n"}
    return string
  end

end
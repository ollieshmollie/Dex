require_relative "phone_number.rb"
require_relative "email.rb"
require 'colored'

module Tact
  class Contact
    include Comparable
    attr_reader :primary_key, :phone_numbers, :emails, :first_name, :last_name
    attr_accessor :index

    def <=>(another_contact)
      full_name <=> another_contact.full_name
    end

    def initialize(first_name, last_name, primary_key)
      @index = nil
      @first_name = first_name
      @last_name = last_name
      @primary_key = primary_key
      @phone_numbers = []
      @emails = []
    end

    def self.from_hash(hash)
      contact = self.new(hash["first_name"], hash["last_name"], hash["id"])
      return contact
    end

    def full_name
      first_name + " " + last_name
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
end
require_relative 'contact'

module Tact
  class Card
    attr_reader :contact
    def initialize(contact)
      @contact = contact
      @phone_numbers = contact.phone_numbers
      @emails = contact.emails
    end

    def to_s
      string = "=" * 40 + "\n"
      string += @contact.to_s
      @phone_numbers.each {|number| string += "\s\s" + number.to_s + "\n"}
      @emails.each {|address| string += "\s\s\s\s" + address.to_s + "\n"}
      string += "=" * 40 + "\n"
    end
  end
end
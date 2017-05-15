module Tact
  class Card
    attr_reader :contact
    def initialize(contact, index="*")
      @contact = contact
      @index = index
    end

    def to_s
      string = "=" * 40 + "\n"
      string += "[#{@index}]".red + " #{@contact.to_s}"
      contact.phone_numbers.each_with_index {|number, i| string += "\s\s" + "[#{i + 1}] " + number.to_s + "\n"}
      contact.emails.each_with_index {|address, i| string += "\s\s\s\s" + "[#{i + 1}] " + address.to_s + "\n"}
      string += "=" * 40 + "\n"
    end
  end
end

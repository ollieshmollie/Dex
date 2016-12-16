require 'colored'

module Dex
  class PhoneNumber
    include Comparable
    attr_accessor :number, :index, :type

    def self.format_number(number)
      n = number.gsub(/[^\d]/, "")
      chars = n.chars
      if chars.count == 10
        chars.insert(3, '-')
        chars.insert(7, '-')
      elsif chars.count == 11
        chars.insert(0, '+')
        chars.insert(2, ' ')
        chars.insert(6, '-')
        chars.insert(10, '-')
      elsif chars.count == 7
        chars.insert(3, '-')
      else
        return n
      end
      return chars.join
    end

    def self.from_hash(hash)
      number = self.new(hash["type"], hash["number"])
      return number
    end

    def <=>(another_number)
      type <=> another_number.type
    end
    
    def initialize(type, number)
      @index = nil
      @type = type
      @number = number
    end

    def to_s
      "[#{index}]" + " #{type.yellow}: #{PhoneNumber.format_number(number).bold}"
    end
  end
end
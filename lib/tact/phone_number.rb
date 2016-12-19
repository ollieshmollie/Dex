require 'colored'
require_relative 'database'

module Tact
  class PhoneNumber
    attr_reader :id
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
      number = self.new(hash["type"], hash["number"], hash["contact_id"], hash["id"])
      return number
    end
    
    def initialize(type, number, contact_id, primary_key=nil)
      @db = Database.new.db
      @id = primary_key
      @index = nil
      @type = type
      @number = number
      @contact_id = contact_id
    end

    def save
      @db.execute("INSERT INTO phone_numbers (type, number, contact_id) values (?, ?, ?);", [@type, @number, @contact_id]) ? true : false
    end

    def to_s
      "[#{index}]" + " #{type.yellow}: #{PhoneNumber.format_number(number).bold}"
    end
  end
end
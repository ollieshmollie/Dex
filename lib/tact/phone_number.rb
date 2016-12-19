require 'colored'
require_relative 'database'

module Tact
  class PhoneNumber
    attr_reader :id
    attr_accessor :number, :index, :type

    @@db = Database.new.db

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

    def self.from_hash(hash, index=nil)
      self.new(hash["type"], hash["number"], hash["contact_id"], hash["id"], index)
    end

    def self.all
      number_hashes = @@db.execute("select * from phone_numbers;")
      number_hashes.map {|n_hash| self.from_hash(n_hash) }
    end

    def self.delete(id)
      @@db.execute("delete from phone_numbers where id = ?;", [id])
    end

    def self.find_by_id(id)
      number_hashes = @@db.execute("select * from phone_numbers where id = ?", [id])
      self.from_hash(number_hashes[0]) if !number_hashes.empty?
    end

    def self.find_by_number(number)
      number_hashes = @@db.execute("select * from phone_numbers where number = ?", [number])
    end
    
    def initialize(type, number, contact_id, primary_key=nil, index=nil)
      @id = primary_key
      @index = index
      @type = type.downcase.capitalize
      @number = number.gsub(/\D/, "")
      @contact_id = contact_id
    end

    def save
      if @id == nil
        if @@db.execute("INSERT INTO phone_numbers (type, number, contact_id) values (?, ?, ?);", [@type, @number, @contact_id])
          @id = @@db.execute("select last_insert_rowid();")[0]["last_insert_rowid()"]
          self
        else
          false
        end
      else
        @@db.execute("update phone_numbers set type = ?, number = ?, contact_id = ? where id = ?;", [@type, @number, @contact_id]) ? self : false
      end
    end

    def to_s
      "[#{index}]" + " #{type.yellow}: #{PhoneNumber.format_number(number).bold}"
    end
  end
end
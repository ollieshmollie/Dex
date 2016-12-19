require 'colored'
require_relative 'phone_number'
require_relative "email"

module Tact
  class Contact
    attr_reader :id, :phone_numbers, :emails, :first_name, :last_name
    attr_accessor :index

    @@db = Database.new.db

    def self.from_hash(hash)
      contact = self.new(hash["first_name"], hash["last_name"], hash["id"])
      return contact
    end

    def self.all
      contact_hashes = @@db.execute("select * from contacts;")
      contact_hashes.map {|c_hash| self.from_hash(c_hash) }
    end

    def initialize(first_name, last_name, primary_key=nil)
      @id = primary_key
      @index = nil
      @first_name = first_name.downcase.capitalize
      @last_name = last_name.downcase.capitalize
      @phone_numbers = []
      @emails = []
    end

    def save
      self.class.db.execute("insert into contacts (first_name, last_name) values (?, ?);", [@first_name, @last_name]) ? true : false
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
require 'colored'
require_relative 'phone_number'
require_relative "email"

module Tact
  class Contact
    attr_reader :id
    attr_accessor :index, :first_name, :last_name

    @@db = Database.new.db

    def self.from_hash(hash)
      contact = self.new(hash["first_name"], hash["last_name"], hash["id"])
    end

    def self.all
      contact_hashes = @@db.execute("select * from contacts;")
      contact_hashes.map {|c_hash| self.from_hash(c_hash) }
    end

    def self.find_by_id(id)
      contact_hashes = @@db.execute("select * from contacts where id = ?", [id])
      self.from_hash(contact_hashes[0]) if !contact_hashes.empty?
    end

    def self.find_by_first_name(first_name)
      results = @@db.execute("select * from contacts where upper(first_name) = upper(?);", [first_name])
      results.map {|c_hash| Contact.from_hash(c_hash) }
    end

    def self.find_by_last_name(last_name)
      results = @@db.execute("select * from contacts where upper(last_name) = upper(?);", [last_name])
    end

    def self.delete(id)
      @@db.execute("delete from contacts where id = ?;", [id]) ? true : false 
    end

    def initialize(first_name, last_name, primary_key=nil)
      @id = primary_key
      @index = nil
      @first_name = first_name.downcase.capitalize
      @last_name = last_name.downcase.capitalize
    end

    def save
      begin
        if @id == nil
          @@db.execute("insert into contacts (first_name, last_name) values (?, ?);", [@first_name, @last_name]) ? true : false
        else
          @@db.execute("update contacts set first_name = ?, last_name = ? where id = ?;", [@first_name, @last_name, @id]) ? true : false
        end
      rescue
        puts "Error: Contact already exists".red 
      end
    end

    def phone_numbers
      number_hashes = @@db.execute("select * from phone_numbers where contact_id = ?", [@id])
      number_hashes.map {|n_hash| PhoneNumber.from_hash(n_hash) }
    end

    def emails
      email_hashes = @@db.execute("select * from emails where contact_id = ?", [@id])
      email_hashes.map {|e_hash| Email.from_hash(e_hash) }
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
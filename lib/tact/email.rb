require_relative 'database'

module Tact
  class Email
    attr_reader :id
    attr_accessor :address, :index

    def self.from_hash(hash)
      address = self.new(hash["address"], hash["contact_id"], hash["id"])
      return address
    end

    def initialize(address, contact_id, primary_key=nil)
      @id = primary_key
      @index = nil
      @address = address
      @contact_id = contact_id
      @db = Database.new
    end

    def save(contact_id)
      @db.execute("insert into emails (address, contact_id) values (?, ?);", [@address, @contact_id]) ? true : false
    end

    def to_s
      "[#{@index}] <#{@address}>"
    end
  end
end
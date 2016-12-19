require_relative 'database'

module Tact
  class Email
    attr_reader :id
    attr_accessor :address, :index

    @@db = Database.new.db

    def self.from_hash(hash, index)
      self.new(hash["address"], hash["contact_id"], hash["id"], index)
    end

    def self.delete(id)
      @@db.execute("delete from emails where id = ?;", [id])
    end

    def initialize(address, contact_id, primary_key=nil, index=nil)
      @id = primary_key
      @index = index
      @address = address
      @contact_id = contact_id
    end

    def save
      if @id == nil
        @@db.execute("insert into emails (address, contact_id) values (?, ?);", [@address, @contact_id]) ? true : false
      else
        @@db.execute("update emails set address = ?, contact_id = ? where id = ?;", [@address, @contact_id]) ? true : false
      end
    end

    def to_s
      "[#{@index}] <#{@address}>"
    end
  end
end
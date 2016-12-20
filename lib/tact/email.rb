require_relative 'database'

module Tact
  class Email
    attr_reader :id
    attr_accessor :address, :index

    @@db = Database.new.db

    def self.from_hash(hash)
      self.new(hash["address"], hash["contact_id"], hash["id"])
    end

    def self.all
      email_hashes = @@db.execute("select * from emails;")
      email_hashes.map {|e_hash| Email.from_hash(e_hash) }
    end

    def self.find_by_id(id)
      email_hashes = @@db.execute("select * from emails where id = ?", [id])
      self.from_hash(email_hashes[0]) if !email_hashes.empty?
    end

    def self.find_by_address(address)
      email_hashes = @@db.execute("select * from emails where address = ?", [address])
      email_hashes.map {|e_hash| self.from_hash(e_hash) }
    end

    def self.delete(id)
      @@db.execute("delete from emails where id = ?;", [id])
      @@db.execute("select changes();")[0]["changes()"] == 1 ? true : false
    end

    def initialize(address, contact_id, primary_key=nil)
      @id = primary_key
      @address = address
      @contact_id = contact_id
    end

    def save
      if @id == nil
        if @@db.execute("insert into emails (address, contact_id) values (?, ?);", [@address, @contact_id])
          @id = @@db.execute("select last_insert_rowid();")[0]["last_insert_rowid()"]
          self
        else
          false
        end
      else
        @@db.execute("update emails set address = ?, contact_id = ? where id = ?;", [@address, @contact_id, @id]) ? self : false
      end
    end

    def to_s
      "<#{@address}>"
    end
  end
end
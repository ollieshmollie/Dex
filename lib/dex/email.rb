module Dex
  class Email
    include Comparable
    attr_reader :primary_key
    attr_accessor :address, :index
    
    def <=>(another_email)
      self.address <=> another_email.address
    end

    def initialize(address, primary_key)
      @index = nil
      @address = address
      @primary_key = primary_key
    end

    def self.from_hash(hash)
      address = self.new(hash["address"], hash["id"])
      return address
    end

    def to_s
      "[#{@index}] <#{@address}>"
    end
  end
end
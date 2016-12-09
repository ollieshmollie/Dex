class Email
  include Comparable
  attr_accessor :address, :index
  
  def <=>(another_email)
    self.address <=> another_email.address
  end

  def initialize(address)
    @index = nil
    @address = address
  end

  def self.from_hash(hash)
    address = self.new(hash["address"])
    address.index = hash["index"]
    return address
  end

  def to_hash
    {index: @index, address: @address}
  end

  def to_s
    "[#{@index}] <#{@address}>"
  end
end
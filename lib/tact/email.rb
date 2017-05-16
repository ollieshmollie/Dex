module Tact
  class Email < ActiveRecord::Base
    belongs_to :contact

    def to_s
      "<#{address}>"
    end

  end
end

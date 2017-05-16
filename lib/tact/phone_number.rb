module Tact
  class PhoneNumber < ActiveRecord::Base
    belongs_to :contact

    before_save :format_number
    before_save do
      self.kind = kind ? kind.downcase.capitalize : "Cell"
    end

    def to_s
      "#{kind.yellow}: #{number.bold}"
    end

    def format_number
      n = number.gsub(/[^\d]/, "")
      self.number = n.gsub(/\A\d?(\d{3})(\d{3})(\d{4})\z/, '(\1) \2-\3')
    end

  end
end

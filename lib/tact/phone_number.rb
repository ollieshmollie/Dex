module Tact
  class PhoneNumber < ActiveRecord::Base
    belongs_to :contact

    before_save :format_number
    before_save do
      type = type.downcase.capitalize
    end

    def to_s
      "#{type.yellow}: #{PhoneNumber.format_number(number).bold}"
    end

    private 

      def format_number
        n = number.gsub(/[^\d]/, "")
        n.gsub(/(\d{3})(\d{3})(\d{4})/, '(\1) \2-\3')
      end

  end
end

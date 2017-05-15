module Tact
  class Contact < ActiveRecord::Base
    has_many :phone_numbers, dependent: :destroy
    has_many :emails, dependent: :destroy

    before_save do
      first_name.upcase!
      last_name.upcase!
    end

    def full_name
      first_name + " " + last_name
    end

    def to_s
      "#{full_name}\n".green.bold
    end
  end
end

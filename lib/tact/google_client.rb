require 'json'

module Tact
  module GoogleContacts
    class Syncer

      def initialize(entry)
        @entry = entry
        @new_numbers = []
        @new_emails = []
      end

      def sync
        contact = find_contact || Contact.new(
          first_name: entry.first_name.upcase,
          last_name: entry.last_name.upcase
        )
        merge_properties(contact)
        contact.save
      end

      def find_contact
        Contact.find_by(
          first_name: entry.first_name.upcase,
          last_name: entry.last_name.upcase
        )
      end

      def merge_properties(contact)
        get_new_phone_numbers(contact)
        get_new_emails(contact)
        add_new_phone_numbers(contact)
        add_new_emails(contact)
      end

      def add_new_phone_numbers(contact)
        contact.phone_numbers << new_numbers
      end

      def add_new_emails(contact)
        contact.emails << new_emails
      end

      def get_new_phone_numbers(contact)
        entry.phone_numbers.each do |number|
          if !contact.phone_numbers.include?(number)
            new_numbers << number
          end
        end
      end

      def get_new_emails(contact)
        entry.emails.each do |email|
          if !contact.emails.include?(email)
            new_emails << email
          end
        end
      end

      private
        attr_reader :entry, :new_numbers, :new_emails

    end

    class Entry
      attr_reader :info

      def self.all
        collection.select { |c| c.pure_contact? }
      end

      def initialize(info)
        @info = info
      end

      def pure_contact?
        !!info[:"gContact$groupMembershipInfo"]
      end

      def phone_numbers
        info[:"gd$phoneNumber"].map do |num|
          PhoneNumber.new(
            kind: num[:label],
            number: num[:$t]
          )
        end
      end

      def emails
        info[:"gd$email"].map do |e|
          Email.new(address: e[:address])
        end
      end

      def google_id
        info[:id][:$t]
      end

      def first_name
        info[:"gd$name"][:"gd$givenName"][:$t]
      end

      def last_name
        info[:"gd$name"][:"gd$familyName"][:$t]
      end
      
      def self.collection
        @@collection ||= Fetcher.fetch.reduce(EntriesCollection.new) do |collection, info|
          collection << new(info)
        end
      end
      
      private_class_method :collection
    end

    class EntriesCollection
      include Enumerable

      def initialize(entries=[])
        @entries = entries
      end

      def <<(entry)
        @entries << entry
      end

      def each
        contacts.each { |c| yield(c) }  
      end
    end

    class Fetcher

      def self.fetch
        json = `curl -H "$(oauth2l header --json client_secret.json https://www.google.com/m8/feeds/)"\
         -H "GData-Version: 3.0" https://www.google.com/m8/feeds/contacts/default/full?alt=json`
        info_list = JSON.parse(json, symbolize_names: true)
        info_list[:feed][:entry]
      end
    end

    private_constant :Fetcher
  end
end

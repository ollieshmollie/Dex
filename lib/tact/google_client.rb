require 'json'

module Tact
  module GoogleContacts

    class Entry
      attr_reader :info

      def self.all
        collection
      end

      def self.pure_contacts
        collection.select { |c| c.pure_contact? }
      end

      def initialize(info)
        @info = info
      end

      def pure_contact?
        !!info[:"gContact$groupMembershipInfo"]
      end

      def to_contact
      end

      private
        
        def build_contact
          Contact.new({
          first_name: first_name,
          last_name: last_name,
          google_id: google_id
        })
        end

        def phone_numbers
          info[:"gd$phoneNumber"]
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

    class EntryPhoneNumber
      def initialize(entry)
        @entry = entry
      end

      def build_phone_number
        PhoneNumber.new({
          type: type,
          number: number 
        }) 
      end 
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

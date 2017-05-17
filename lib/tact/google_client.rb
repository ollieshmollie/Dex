require 'json'

module Tact
  module GoogleContacts

    class Entry
      attr_reader :info

      def self.all
        collection
      end

      def initialize(info)
        @info = info
      end

      def first_name
        names[:givenName]
      end

      def last_name
        names[:familyName]
      end

      def phone_numbers
        if info[:phoneNumbers]
          info[:phoneNumbers].map do |phone_number|
            PhoneNumber.new(
              number: phone_number[:value],
              kind: phone_number[:type]
            )
          end
        end
      end

      def emails
        if info[:emailAddresses]
          info[:emailAddresses].map do |email_address|
            Email.new(address: email_address[:value])
          end 
        end
      end

      private

        def names
          info[:names][0]
        end

      def self.collection
        @@collection ||= Fetcher.info_list.reduce(EntriesCollection.new) do |collection, info|
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
        @entries.each { |c| yield(c) }  
      end
    end
    

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
          if !contact.phone_numbers.any? { |n| n.number == number.number }
            new_numbers << number
          end
        end if entry.phone_numbers
      end

      def get_new_emails(contact)
        entry.emails.each do |email|
          if !contact.emails.any? { |e| e.address == email.address }
            new_emails << email
          end
        end if entry.emails
      end

      private
        attr_reader :entry, :new_numbers, :new_emails

    end

    
    class Fetcher

      def self.info_list
        info = JSON.parse(json, symbolize_names: true)
        if info[:error]
          puts "ERROR: Please authorize your Google account.".red 
          exit
        end
        info[:connections]  
      end

      def self.json
        `curl -H "$(oauth2l header --json #{CLIENT_SECRET} https://www.googleapis.com/auth/contacts https://www.googleapis.com/auth/contacts.readonly)"\
          https://people.googleapis.com/v1/people/me/connections?requestMask.includeField=person.names,person.phone_numbers,person.email_addresses`
      end
    end

  end
end

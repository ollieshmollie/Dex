require 'json'

module Tact
  class GoogleClient
    attr_reader :doc

    def initialize
      @doc = JSON.parse(fetch_contacts, symbolize_names: true)
    end

    def entries
      doc[:feed][:entry].reject { |e| e[:"gContact$groupMembershipInfo"].nil? }
    end

    private

      def fetch_contacts
        `curl -H "$(oauth2l header --json client_secret.json https://www.google.com/m8/feeds/)" -H "GData-Version: 3.0" https://www.google.com/m8/feeds/contacts/default/full?alt=json`
      end

  end

  class GoogleClientEntry
    attr_reader :info

    def initialize(entry)
      @info = entry
    end
  
    def to_contact
    end

    def titled?
      !info[:title][:$t].empty?
    end
      
  end
end

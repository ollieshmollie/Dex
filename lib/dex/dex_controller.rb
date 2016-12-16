require_relative "dex.rb"
require 'optparse'
require 'dex/version'

module Dex
  class DexController
    def initialize(args)
      @dex = Dex.new
      @options = {}
      @opt_parser = OptionParser.new do |opt|
        opt.banner = "Usage: dex [COMMAND] [OPTIONS] [ARGUMENTS]"
        opt.on('-n', '--name', 'Edit name') do
          @options[:name] = true
        end
        opt.on('-p', '--phone', 'Edit phone number') do
          @options[:number] = true
        end
        opt.on('-e', '--email', 'Edit email') do
          @options[:email] = true
        end
        opt.on('-f', '--first', 'By first name') do
          @options[:first] = true
        end
        opt.on('-l', '--last', 'By last name') do
          @options[:last] = true        
        end
        opt.on("-v", "--version", "Version") do 
          @options[:version] = true
        end
        opt.on("-h", "--help", "Help") do
          @options[:help] = true
        end
      end
      @opt_parser.parse!
      @command = args.shift
      @args = args
    end

    def help_message
      <<~EOF
      Usage:
        -v                                Current version
        -h                                Help

        add first last                    Adds new name
        add index -p type num             Adds contact number
        add index -e address              Adds contact email
        rm index                          Deletes contact
        rm index -p num_index             Deletes contact number
        rm index -e e_index               Deletes contact email
        edit index first last             Edits contact name
        edit index -p num_index type num  Edits contact number
        edit index -e e_index address     Edits contact email
        find <param>                      Search by name
        find -p <param>                   Search by number
        find -e <param>                   Search by email
      EOF
    end

    def run
      if !args_are_valid?
        puts "Invalid input"
        puts help_message
        exit
      end

      case @command

      when "find"
        param = @args[0]
        if @options.empty?
          puts @dex.find_by_name(param)
        elsif @options[:number]
          puts @dex.find_by_number(param)
        elsif @options[:email]
          puts @dex.find_by_email(param)
        end

      when "add"
        if @options.empty?
          first_name = @args[0]
          last_name = @args[1]
          @dex.add_contact(first_name, last_name)
        elsif @options[:number]
          contact_index = @args[0].to_i
          type = @args[1]
          number = @args[2]
          @dex.add_phone_number(contact_index, type, number)
        elsif @options[:email]
          contact_index = @args[0].to_i
          address = @args[1]
          @dex.add_email(contact_index, address)
        end

      when "rm"
        if @options.empty?
          contact_index = @args[0].to_i
          @dex.delete_contact(contact_index)
        elsif @options[:number]
          contact_index = @args[0].to_i
          number_index = @args[1].to_i
          @dex.delete_phone_number(contact_index, number_index)
        elsif @options[:email]
          contact_index = @args[0].to_i
          email_index = @args[1].to_i
          @dex.delete_email(contact_index, email_index)
        end

      when "edit"
        if @options.empty?
          contact_index = @args[0].to_i
          first_name = @args[1]
          last_name = @args[2]
          @dex.edit_contact_name(contact_index, first_name, last_name)
        elsif @options[:number]
          contact_index = @args[0].to_i
          number_index = @args[1].to_i
          new_type = @args[2]
          new_number = @args[3]
          @dex.edit_phone_number(contact_index, number_index, new_type, new_number)
        elsif @options[:email]
          contact_index = @args[0].to_i
          email_index = @args[1].to_i
          new_address = @args[2]
          @dex.edit_email(contact_index, email_index, new_address)
        end
        
      when nil
        if @options[:help]
          puts help_message
        elsif @options[:version]
          puts VERSION
        else
          print @dex
        end

      end

    end

    def args_are_valid?
      case @command
      when "find"
        return false if !@options.empty? && !@options[:number] && !@options[:email]
        return true
      when "add"
        return false if @options.count > 1
        return false if !@options.empty? && !@options[:name] && !@options[:number] && !@options[:email]
        return false if @options[:name] && @args.count != 2
        return false if @options[:number] && @args.count != 3
        return false if @options[:email] && @args.count != 2
        return false if @options[:number] && @args[0].to_i == 0 && @args[0] != "0"
        return false if @options[:email] && @args[0].to_i == 0 && @args[0] != "0"
        return true
      when "rm"
        return false if @options.count > 1
        return false if !@options.empty? && !@options[:number] && !@options[:email]
        return false if @options.count == 0 && @args.count != 1
        return false if @args[0].to_i == 0 && @args[0] != "0"
        return false if @options[:number] && @args.count != 2
        return false if @options[:number] && @args[1].to_i == 0 && @args[1] != "0"
        return false if @options[:email] && @args.count != 2
        return false if @options[:email] && @args[1].to_i == 0 && @args[1] != "0"
        return true
      when "edit"
        return false if @options.count > 1
        return false if !@options.empty? && !@options[:number] && !@options[:email]
        return false if @options.empty? && @args.count != 3
        return false if @options[:number] && @args.count != 4
        return false if @options[:email] && @args.count != 3
        return false if @args[0].to_i == 0 && @args[0] != "0"
        return false if @options[:number] && @args[1].to_i == 0 && @args[1] != "0"
        return false if @options[:email] && @args[1].to_i == 0 && @args[1] != "0"
        return true
      when nil
        return false if @options.count > 1
        return false if @options.count == 1 && (!@options[:help] && !@options[:version])
        return true
      else
        return false
      end
    end
  end
end
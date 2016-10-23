require_relative "./dex.rb"
require 'optparse'

class DexManager
  def initialize(args)
    @dex = Dex.new
    @options = {}
    @version = "dex version 1.1"
    @opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: dex [COMMAND] [OPTIONS] [ARGUMENTS]"
      opt.on('-n', '--name', 'Edit name') do
        @options[:name] = true
      end
      opt.on('-t', '--phone', 'Edit phone number') do
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

      add first last type num           Adds new contact
      add -n first last                 Adds new name
      add -t index type num             Adds contact number
      add -e index address              Adds contact email
      delete index                      Deletes contact
      delete -t index num_index         Deletes contact number
      delete -e index e_index           Deletes contact email
      edit -n index first last          Edits contact name
      edit -t index num_index type num  Edits contact number
      edit -e index e_index address     Edits contact email
      find -n <param>                   Searches by name (DEFAULT)
      find -t <param>                   Searches by number
      find -e <param>                   Searches by email
      find -f <letter>                  Names by first name letter
      find -l <letter>                  Names by last name letter
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
      if @options.empty? || @options[:name]
        param = @args[0]
        puts @dex.find_by_name(param)
      elsif @options[:number]
        param = @args[0]
        puts @dex.find_by_number(param)
      elsif @options[:email]
        param = @args[0]
        puts @dex.find_by_email(param)
      elsif @options[:first]
        param = @args[0].downcase
        puts @dex.find_by_first_name_letter(param)
      elsif @options[:last]
        param = @args[0].downcase
        puts @dex.find_by_last_name_letter(param)
      end

    when "add"
      if @options.empty?
        first_name = @args[0].downcase
        last_name = @args[1].downcase
        type = @args[2].downcase
        number = @args[3]
        contact = Contact.new(first_name, last_name)
        contact.add_phone_number(type, number)
        @dex.add(contact)
        @dex.save
        puts contact
      elsif @options[:name]
        first_name = @args[0].downcase
        last_name = @args[1].downcase
        contact = Contact.new(first_name, last_name)
        @dex.add(contact)
        @dex.save
        puts contact
      elsif @options[:number]
        index = @args[0].to_i
        type = @args[1].downcase
        number = @args[2]
        contact = @dex.contact_at_index(index)
        if contact
          contact.add_phone_number(type, number)
          @dex.save
          puts contact
        else
          puts "Contact index out of range".red
        end
      elsif @options[:email]
        index = @args[0].to_i
        address = @args[1]
        contact = @dex.contact_at_index(index)
        if contact
          contact.add_email(address)
          @dex.save
          puts contact
        else
          puts "Contact index out of range".red
        end
      end

    when "delete"
      if @options.empty?
        index = @args[0].to_i
        contact = @dex.delete(index)
        puts contact if contact
        puts "Index out of range".red if !contact
      elsif @options[:number]
        contact_index = @args[0].to_i
        number_index = @args[1].to_i
        contact = @dex.contact_at_index(contact_index)
        if contact
          if contact.delete_phone_number(number_index)
            @dex.save
            puts contact
          else
            puts "Phone number index out of range".red
          end
        else
          puts "Contact index out of range".red
        end
      elsif @options[:email]
        contact_index = @args[0].to_i
        email_index = @args[1].to_i
        contact = @dex.contact_at_index(contact_index)
        if contact
          if contact.delete_email(email_index)
            @dex.save
            puts contact
          else
            puts "Email index out of range".red
          end
        else
          puts "Contact index out of range".red
        end
      end

    when "edit"
      if @options[:name]
        index = @args[0].to_i
        first_name = @args[1].downcase
        last_name = @args[2].downcase
        contact = @dex.contact_at_index(index)
        if contact
          contact.first_name = first_name.capitalize
          contact.last_name = last_name.capitalize
          @dex.save
          puts contact
        else
          puts "Contact index out of range".red
        end
      elsif @options[:number]
        contact_index = @args[0].to_i
        number_index = @args[1].to_i
        new_type = @args[2].downcase
        new_number = @args[3]
        contact = @dex.contact_at_index(contact_index)
        if contact
          if contact.update_phone_number(number_index, new_type, new_number)
            puts contact
            @dex.save
          else
            puts "Number index out of range".red
          end
        else
          puts "Contact index out of range".red
        end
      elsif @options[:email]
        contact_index = @args[0].to_i
        email_index = @args[1].to_i
        new_address = @args[2]
        contact = @dex.contact_at_index(contact_index)
        if contact
          if contact.update_email(email_index, new_address)
            puts contact
            @dex.save
          else
            puts "Email index out of range".red
          end
        else
          puts "Contact index of out range".red
        end
      end

    when nil
      if @options[:help]
        puts help_message
      elsif @options[:version]
        puts @version
      else
        puts "--No saved contacts".red if @dex.contacts.empty?
        puts @dex if !@dex.contacts.empty?
      end

    end

  end

  def args_are_valid?
    case @command
    when "find"
      return false if @args.count != 1
      return false if @options.count > 1
      return false if !@options.empty? && !@options[:name] && !@options[:number] && !@options[:email] && !@options[:first] && !@options[:last]
      return false if (@options[:first] || @options[:last]) && @args[0].length != 1
      return true
    when "add"
      return false if @options.empty? && @args.count != 4
      return false if @options.count > 1
      return false if !@options.empty? && !@options[:name] && !@options[:number] && !@options[:email]
      return false if @options[:name] && @args.count != 2
      return false if @options[:number] && @args.count != 3
      return false if @options[:email] && @args.count != 2
      return false if @options[:number] && @args[0].to_i == 0 && @args[0] != "0"
      return false if @options[:email] && @args[0].to_i == 0 && @args[0] != "0"
      return true
    when "delete"
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
      return false if @options.count != 1
      return false if !@options[:name] && !@options[:number] && !@options[:email]
      return false if @options[:name] && @args.count != 3
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
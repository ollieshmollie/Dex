require_relative "./dex.rb"
require 'optparse'

class DexManager
  def initialize(args)
    @dex = Dex.new
    @options = {}
    @version = "dex version 1.0"
    @opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: dex [COMMAND] [OPTIONS] [ARGUMENTS]"
      opt.on('-n', '--name', 'Edit name') do
        @options[:name] = true
      end
      opt.on('-t', '--phone', 'Edit phone number') do
        @options[:number] = true
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
      add first last type num           Adds new contact
      add -n first last                 Adds name only
      add -t index type num             Adds number to contact
      delete index                      Deletes contact
      delete -t index num_index         Deletes number from contact
      edit -n index new_first new_last  Edits name of contact
      edit -t index num_index type num  Edits number of contact
      find -n <param>                   Searches contacts by name (DEFAULT)
      find -t <param>                   Searches contacts by number
    EOF
  end

  def run
    if !args_are_valid?
      puts "command not found"
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
        contact = @dex.contacts[index]
        contact.add_phone_number(type, number)
        @dex.save
        puts contact
      end
    when "delete"
      if @options[:number]
        contact_index = @args[0].to_i
        number_index = @args[1].to_i
        contact = @dex.contacts[contact_index]
        contact.delete_phone_number(number_index)
        @dex.save
        puts contact
      else
        index = @args[0].to_i
        contact = @dex.delete(index)
        puts contact if contact
        puts "Can't find a contact at index #{index}".red if !contact
      end
    when "edit"
      if @options[:name]
        index = @args[0].to_i
        first_name = @args[1].downcase
        last_name = @args[2].downcase
        contact = @dex.update_name(index, first_name, last_name)
        puts contact if contact
        puts "Can't find a contact at index #{index}".red if !contact
      elsif @options[:number]
        contact_index = @args[0].to_i
        number_index = @args[1].to_i
        type = @args[2].downcase
        number = @args[3]
        contact = @dex.update_number(contact_index, number_index, type, number)
        puts contact if contact
        puts "Can't find a contact at index #{index}".red if !contact
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
      return true
    when "add"
      return false if @options.empty? && @args.count != 4
      return false if @options.count > 1
      return false if @options[:name] && @args.count != 2
      return false if @options[:number] && @args.count != 3
      return false if @options[:number] && @args[0].to_i == 0 && @args[0] != "0"
      return true
    when "delete"
      return false if @options.count > 1
      return false if @options.count == 0 && @args.count != 1
      return false if @args[0].to_i == 0 && @args[0] != "0"
      return false if @options[:number] && @args[1].to_i == 0 && @args[1] != "0"
      return false if @options.count ==1 && !@options[:number]
      return true
    when "edit"
      return false if @options.count != 1
      return false if @options[:name] && @args.count != 3
      return false if @options[:number] && @args.count != 4
      return false if @args[0].to_i == 0 && @args[0] != "0"
      return false if @options[:number] && @args[1].to_i == 0 && @args[1] != "0"
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
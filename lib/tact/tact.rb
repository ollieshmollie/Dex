module Tact
  class Tact
    def initialize(args)
      @dex = Rolodex.new
      @options = {}
      begin
        OptionParser.new do |opt|
          opt.banner = "Usage: tact [OPTIONS] [ARGUMENTS]"
          opt.on('-n', '--new', 'New entry') do
            @options[:new] = true
          end
          opt.on('-u', '--update', 'Update entry') do
            @options[:update] = true 
          end
          opt.on('-d', '--delete', 'Delete entry') do
            @options[:delete] = true
          end
          opt.on('-p', '--phone', 'Edit phone number') do
            @options[:number] = true
          end
          opt.on('-e', '--email', 'Edit email') do
            @options[:email] = true
          end
          opt.on("-v", "--version", "Version") do 
            @options[:version] = true
          end
          opt.on("-h", "--help", "Help") do
            @options[:help] = true
          end
        end.parse!
      rescue
        puts "Invalid option".red
        puts help_message
      end
      @args = args
    end

    def help_message
      <<~EOF
  
        -v                                    Current version
        -h                                    Help

        <param>                               Search by name
        -p <param>                            Search by number
        -e <param>                            Search by email
        -n <first> <last>                     Adds new name
        -np <index> <type> <num>              Adds contact number
        -ne <index> <address>                 Adds contact email
        -d <index>                            Deletes contact
        -dp <index> <num_index>               Deletes contact number
        -de <index> <e_index>                 Deletes contact email
        -u <index> <first> <last>             Edits contact name
        -up <index> <num_index> <type> <num>  Edits contact number
        -ue <index> <e_index> <address>       Edits contact email

      EOF
    end

    def run
      if !args_are_valid?
        puts "Error: Invalid input".red
        puts help_message
        exit
      end

      if @options[:new]
        if !@options[:number] && !@options[:email]
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
      
      elsif @options[:delete]
        if !@options[:number] && !@options[:email]
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

      elsif @options[:update]
        if !@options[:number] && !@options[:email]
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
        
      elsif @options[:help]
        puts help_message
      elsif @options[:version]
        puts "tact version #{VERSION}"
      else
        if @args.empty?
          print @dex
        else
          params = @args.join(' ')
          if @options.empty?
            puts @dex.find_by_name(params)
          elsif @options[:number]
            puts @dex.find_by_number(params)
          elsif @options[:email]
            puts @dex.find_by_email(params)
          end
        end
      end
    end

    def args_are_valid?
      case 

      when @options[:new]
        return false if @options[:delete] || @options[:version] || @options[:update] || @options[:help]
        if @options[:number]
          return false if @options[:email]
          return false if @args.length != 3
          return false if @args[0].to_i == 0
        elsif @options[:email]
          return false if @args.length != 2
          return false if @args[0].to_i == 0
        else
          return false if @args.length != 2
        end
        true

      when @options[:delete]
        return false if @options[:new] || @options[:version] || @options[:update] || @options[:help]
        if @options[:number]
          return false if @options[:email]
          return false if @args.length != 2
          return false if @args[0].to_i == 0
          return false if @args[1].to_i == 0
        elsif @options[:email]
          return false if @options[:number]
          return false if @args.length != 2
          return false if @args[0].to_i == 0
          return false if @args[1].to_i == 0
        else
          return false if @args.length != 1
          return false if @args[0].to_i == 0
        end
        true
      
      when @options[:update]
        return false if @options[:new] || @options[:version] || @options[:delete] || @options[:help]
        if @options[:number]
          return false if @options[:email]
          return false if @args.length != 4
          return false if @args[0].to_i == 0
        elsif @options[:email]
          return false if @options[:number]
          return false if @args.length != 3
          return false if @args[0].to_i == 0
        else
          return false if @args.length != 3
          return false if @args[0].to_i == 0
        end
        true
      
      when @options[:help]
        return false if @options[:new] || @options[:version] || @options[:delete] || @options[:update]
        true

      when @options[:version]
        return false if @options[:new] || @options[:update] || @options[:delete] || @options[:help]
        true
      
      else
        true
      end
    end
  end
end

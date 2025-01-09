def start_console
    Thread.new do
      loop do
        print "\n> " # Prompt for console input
        input = gets.chomp.strip
        
        case input.downcase
        when 'list'
          puts "Connected users:"
          @clients.each_key { |user| puts "\t* ".green + "#{user}" }
        when 'help'
          puts "Available commands:\n\tlist - list of connected users\n\tpkl - display ASCII art\n\tbroadcast <message> - send a message on behalf of the server\n\tshutdown - power off server"
        when 'pkl'
          puts File.read("ascii.txt").yellow
        when /^broadcast\s+(.*)$/i # Regular expression to match 'broadcast <message>'
          message = $1.strip # Extract the message after 'broadcast'
          if message.empty?
            puts "Broadcast message cannot be empty."
          else
            broadcast("[Server]: " + "#{message}".yellow) # Broadcast the message to all clients
            puts "Message broadcasted: #{message}"
          end
        when 'shutdown'
          puts "Shutting down the server..."
          broadcast("Server is shutting down...")
          @server.close # Close the server socket to stop accepting new clients.
          exit # Exit the program.
        else
            if != nil
                puts "Unknown command. Available commands - help"
            end
        end
      end
    end
  end
  
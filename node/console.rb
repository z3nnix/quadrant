def start_console
  Thread.new do
    loop do
      print "> "
      input = gets.chomp.strip
      
      case input.downcase
      when 'list'
        puts "Connected users:"
        @clients.each_key { |user| puts "\t* ".green + "#{user}" }
      when 'help'
        puts "Available commands:\n\tlist - list of connected users\n\tpkl - display ASCII art\n\tbroadcast <message> - send a message on behalf of the server\n\tshutdown - power off server"
      when 'pkl'
        puts File.read("ascii.txt").yellow
      when /^broadcast\s*(.*)$/i
        message = $1.strip
        if message.empty?
          puts "broadcast: message cannot be empty."
        else
          case message.downcase
          when "pkl"
            broadcast("[Server]:\n".yellow + File.read("ascii.txt").yellow)
          when "list"
            broadcast("[Server]:\n\t" + "Connected users:")
            @clients.each_key { |user| broadcast("\t\t* ".green + "#{user}") }
          else
            broadcast("[Server]: ".yellow + "#{message}")
            puts "Message broadcasted: #{message}"
          end
        end
      when 'shutdown'
        broadcast("Server is shutting down...")
        sleep(4)
        @server.close
        exit
      else
        unless input.empty?
          puts "Unknown command. Available commands - help"
        end
      end
    end
  end
end

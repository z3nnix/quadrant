require 'socket'
require_relative '../node/colors.rb'

class IRCBot
  def initialize(server, port, username)
    @server = server
    @port = port
    @username = username
    @socket = TCPSocket.open(server, port)
    @socket.puts username
    puts "Connected to #{@server} on port #{@port} as #{@username}"
  end

  def run
    Thread.new { listen }
    send_messages
  end

  def listen
    loop do
      msg = @socket.gets
      if msg
        puts msg.chomp
        handle_message(msg.chomp)
      else
        puts "Disconnected from the server"
        break
      end
    end
  end

  def send_messages
    loop do
      sleep(1)
    end
  rescue Interrupt
    @socket.close
    puts "\nDisconnected from the server"
    exit
  end

  private

  def handle_message(message)
    if message.include?("/ping")
      send_pong
    end
  end

  def send_pong
    @socket.puts "pong"
  end
end

if __FILE__ == $0
  server = "127.0.0.1"
  port = "6666"
  username = "BugagashBot"

  bot = IRCBot.new(server, port, username)
  bot.run
end
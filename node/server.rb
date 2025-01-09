require 'socket'
require_relative "colors.rb"
require_relative "console"

class QuadrantServer
  def initialize(port = 6666)
    @server = TCPServer.new(port)
    @clients = {}
    puts "[Quadrant]: Server started on port #{port}"
    start_console
  end

  def run
    loop do
      client = @server.accept
      Thread.new(client) { |conn| handle_client(conn) }
    end
  end

  def handle_client(client)
    username = client.gets&.strip
    if username.nil? || username.empty?
      client.puts "ERROR: Invalid username"
      client.close
      return
    end

    @clients[username] = { client: client, channel: nil }
    broadcast("#{username} has joined the chat".black_on_cyan)

    loop do
      msg = client.gets&.strip
      if msg.nil?
        handle_disconnection(username, client)
        break
      end
      handle_message(username, msg)
    end
  rescue IOError => e
    puts "IOError: #{e.message} for user: #{username}"
    handle_disconnection(username, client)
  rescue StandardError => e
    puts "Error: #{e.message}"
    handle_disconnection(username, client)
  end

  def handle_disconnection(username, client)
    @clients.delete(username)
    broadcast("#{username} has left the chat".black_on_cyan)
    client.close unless client.closed?
  end

  def handle_message(username, msg)
    if msg.start_with?('/join')
      channel = msg.split(' ').last
      @clients[username][:channel] = channel
      @clients[username][:client].puts "You have joined #{channel}"
    elsif msg.start_with?('/msg')
      target, message = msg.split(' ')[1], msg.split(' ', 3).last
      send_message(username, target, message)
    else
      if msg && !msg.strip.empty?
        time = Time.now.strftime("%H:%M")
        puts "[#{time}]: #{msg}"
        broadcast("#{time} ".gray + "#{username}> ".yellow + "#{msg}", @clients[username][:channel])
      else
        time = Time.now.strftime("%H:%M")
        puts "[#{time}]: someone sent empty message"
      end
    end
  end

  def send_message(from, to, msg)
    if @clients[to]
      @clients[to][:client].puts "#{from} whispers: #{msg}"
    else
      @clients[from][:client].puts "User #{to} not found"
    end
  rescue IOError => e
      puts "Failed to send message to #{to}: #{e.message}"
  end

  def broadcast(msg, channel = nil)
    @clients.each do |_, client_info|
      if channel.nil? || client_info[:channel] == channel
        begin
          client_info[:client].puts msg unless client_info[:client].closed?
        rescue IOError => e
          puts "Failed to broadcast message: #{e.message}"
        end
      end
    end
  end
end

server = QuadrantServer.new
server.run

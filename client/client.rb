require "socket"

class QuadrantClient
  HISTORY_SIZE = 128

  def initialize(server, port, username)
    @server = server
    @port = port
    @username = username
    connect
    @history = []
    puts "Connected to #{@server} on port #{@port} as #{@username}"
  end

  def run
    Thread.new { listen }
    send_messages
  end

  def listen
    loop do
      print("> ")
      msg = @socket.gets
      if msg && !msg.strip.empty?
        add_to_history(msg.chomp)
        system("clear")
        display_history
      else
        puts "Disconnected from the server"
        reconnect
        break
      end
    end
  end

  def send_messages
    loop do
      msg = $stdin.gets.chomp
      if !msg.strip.empty?
        @socket.puts msg unless @socket.closed?
      else
        system("clear")
        display_history
        print "> "
      end
    end
  rescue Interrupt
    disconnect
  end

  private

  def connect
    @socket = TCPSocket.open(@server, @port)
    @socket.puts @username
  rescue Errno::ECONNREFUSED => e
    puts "Connection failed: #{e.message}. Retrying in 10 seconds..."
    sleep 10
    retry
  end

  def disconnect
    @socket.close unless @socket.closed?
    puts "\nDisconnected from the server"
  end

  def reconnect
    disconnect
    
    loop do
      begin
        puts "Attempting to reconnect..."
        connect
        puts "Reconnected to #{@server} on port #{@port} as #{@username}"
        break
      rescue Errno::ECONNREFUSED => e
        puts "Reconnect failed: #{e.message}. Retrying in 10 seconds..."
        sleep 10
      end
    end
    Thread.new { listen }
  end

  def add_to_history(message)
    @history.push(message)
    @history.shift if @history.size > HISTORY_SIZE
  end

  def display_history
    @history.each { |msg| puts msg }
  end
end

if __FILE__ == $0
  server = "127.0.0.1"
  port = "6666"

  print "Enter your username: "
  username = gets.chomp

  client = QuadrantClient.new(server, port, username)
  client.run
end

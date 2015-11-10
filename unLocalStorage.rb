require 'socket' # Provides TCPServer and TCPSocket classes
require 'uri'
require 'json'
unless File.exists? "tokens.json"
  File.open("tokens.json", "w") {|f|
    f.write("")
  }
end

# Initialize a TCPServer object that will listen
# on localhost:2345 for incoming connections.
server = TCPServer.new('localhost', 6686)# connection at a time.
loop do
  begin
    socket       = server.accept
    request_line = socket.gets

    puts request_line
    if request_line.nil?
      next
    end
    req = request_line.split(" ")
    response = ""

    case req[0]
    when "GET"
      if req[1] == "/get_tokens"
        puts "get tokens"
        File.open("tokens.json", "r") {|f|
          response = f.read
        }
      end
      socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: text/json\r\n" +
                   "Content-Length: #{response.bytesize}\r\n" +
                   "Connection: close\r\n" +
                   "Access-Control-Allow-Origin: *\r\n"
      socket.print "\r\n"
      socket.print response
    when "POST"
      if req[1].start_with? "/set_tokens"
        puts "set tokens"
        until socket.gets.length == 2
        end
        socket.print "HTTP/1.1 200 OK\r\n" +
                     "Content-Type: text/plain\r\n" +
                     "Content-Length: 2\r\n" +
                     "Connection: close\r\n" +
                     "Access-Control-Allow-Origin: *\r\n"
        socket.print "\r\n \r\n"
        restString = req[1][12..-1]
        hm = Hash.new
        (restString.split("&").map {|o| o.split("=")}).each {|o| hm[o[0]] = o[1]}
        puts hm
        hm_orig = hm
        if File.stat("tokens.json").size > 0
          hm_orig = JSON.parse(File.read("tokens.json"))
          hm.keys.each do |o|
            hm_orig[o] = hm[o]
          end
        end
        File.open("tokens.json", "w") {|f|
          f.write(hm_orig.to_json)
        }
      elsif req[1].start_with? "/kill"
        File.open("tokens.json", "w") {|f|
          f.write("")
        }
        socket.print "HTTP/1.1 200 OK\r\n" +
                     "Content-Type: text/plain\r\n" +
                     "Content-Length: 2\r\n" +
                     "Connection: close\r\n" +
                     "Access-Control-Allow-Origin: *\r\n"
        socket.print "\r\n \r\n"
      end
    else
      puts "GET FKD"
      response = "NOPE!\n"
      socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: text/plain\r\n" +
                   "Content-Length: #{response.bytesize}\r\n" +
                   "Connection: close\r\n" +
                   "Access-Control-Allow-Origin: *\r\n"

      socket.print "\r\n"
      socket.print response
    end
    socket.close
  rescue => error
    puts "oh no an error :("
    puts "#{error.class} and #{error.message}"
  end
end
